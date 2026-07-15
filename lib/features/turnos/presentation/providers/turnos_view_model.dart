import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/turnos_state_entity.dart';
import '../../domain/usecases/add_participant_usecase.dart';
import '../../domain/usecases/auto_assign_gaseosa_day_usecase.dart';
import '../../domain/usecases/auto_assign_weekly_vasos_usecase.dart';
import '../../domain/usecases/generate_week_usecase.dart';
import '../../domain/usecases/load_turnos_usecase.dart';
import '../../domain/usecases/manual_set_gaseosa_usecase.dart';
import '../../domain/usecases/manual_set_weekly_vasos_usecase.dart';
import '../../domain/usecases/remove_participant_usecase.dart';
import '../../domain/usecases/rename_participant_usecase.dart';
import '../../domain/usecases/save_turnos_usecase.dart';
import '../../domain/usecases/set_presence_usecase.dart';
import '../../domain/usecases/toggle_day_lock_usecase.dart';
import '../../domain/usecases/toggle_participant_active_usecase.dart';
import '../../domain/usecases/toggle_week_vasos_lock_usecase.dart';

/// Bundle de usecases para no inflar el constructor del ViewModel.
class TurnosUseCases {
  final LoadTurnosUseCase load;
  final SaveTurnosUseCase save;
  final GenerateWeekUseCase generateWeek;
  final AutoAssignGaseosaDayUseCase autoAssignGaseosaDay;
  final AutoAssignWeeklyVasosUseCase autoAssignWeeklyVasos;
  final ManualSetGaseosaUseCase manualSetGaseosa;
  final ManualSetWeeklyVasosUseCase manualSetWeeklyVasos;
  final SetPresenceUseCase setPresence;
  final ToggleDayLockUseCase toggleDayLock;
  final ToggleWeekVasosLockUseCase toggleWeekVasosLock;
  final AddParticipantUseCase addParticipant;
  final RenameParticipantUseCase renameParticipant;
  final ToggleParticipantActiveUseCase toggleParticipantActive;
  final RemoveParticipantUseCase removeParticipant;

  const TurnosUseCases({
    required this.load,
    required this.save,
    required this.generateWeek,
    required this.autoAssignGaseosaDay,
    required this.autoAssignWeeklyVasos,
    required this.manualSetGaseosa,
    required this.manualSetWeeklyVasos,
    required this.setPresence,
    required this.toggleDayLock,
    required this.toggleWeekVasosLock,
    required this.addParticipant,
    required this.renameParticipant,
    required this.toggleParticipantActive,
    required this.removeParticipant,
  });
}

const Object _unset = Object();

class TurnosUiState {
  final bool loading;
  final TurnosStateEntity data;

  /// Lunes ISO de la semana visible en la pantalla "Semana".
  final String selectedMonday;
  final String? error;

  const TurnosUiState({
    this.loading = true,
    this.data = const TurnosStateEntity(),
    required this.selectedMonday,
    this.error,
  });

  TurnosUiState copyWith({
    bool? loading,
    TurnosStateEntity? data,
    String? selectedMonday,
    Object? error = _unset,
  }) {
    return TurnosUiState(
      loading: loading ?? this.loading,
      data: data ?? this.data,
      selectedMonday: selectedMonday ?? this.selectedMonday,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

class TurnosViewModel extends StateNotifier<TurnosUiState> {
  final TurnosUseCases usecases;

  TurnosViewModel(this.usecases)
    : super(
        TurnosUiState(
          selectedMonday: AppDateUtils.activeMondayIso(DateTime.now()),
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    final result = await usecases.load();
    result.fold(
      (failure) =>
          state = state.copyWith(loading: false, error: failure.message),
      (data) => state = state.copyWith(loading: false, data: data, error: null),
    );
  }

  /// Aplica una mutación pura del estado de dominio y la persiste.
  Future<void> _commit(TurnosStateEntity next) async {
    state = state.copyWith(data: next);
    final result = await usecases.save(next);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {},
    );
  }

  void clearError() => state = state.copyWith(error: null);

  // ── Navegación de semana ────────────────────────────────────────────────

  void goPreviousWeek() => state = state.copyWith(
    selectedMonday: AppDateUtils.previousMonday(state.selectedMonday),
  );

  void goNextWeek() => state = state.copyWith(
    selectedMonday: AppDateUtils.nextMonday(state.selectedMonday),
  );

  void goCurrentWeek() => state = state.copyWith(
    selectedMonday: AppDateUtils.activeMondayIso(DateTime.now()),
  );

  // ── Generación y asignaciones ───────────────────────────────────────────

  Future<void> generateWeek() =>
      _commit(usecases.generateWeek(state.data, state.selectedMonday));

  Future<void> autoAssignDay(String dateIso) =>
      _commit(usecases.autoAssignGaseosaDay(state.data, dateIso));

  Future<void> autoAssignVasos() =>
      _commit(usecases.autoAssignWeeklyVasos(state.data, state.selectedMonday));

  Future<void> setGaseosa(String dateIso, String? personId) =>
      _commit(usecases.manualSetGaseosa(state.data, dateIso, personId));

  Future<void> setVasos(String? personId) => _commit(
    usecases.manualSetWeeklyVasos(state.data, state.selectedMonday, personId),
  );

  Future<void> setPresence(String dateIso, List<String> present) =>
      _commit(usecases.setPresence(state.data, dateIso, present));

  Future<void> toggleDayLock(String dateIso) =>
      _commit(usecases.toggleDayLock(state.data, dateIso));

  Future<void> toggleVasosLock() =>
      _commit(usecases.toggleWeekVasosLock(state.data, state.selectedMonday));

  // ── Participantes ───────────────────────────────────────────────────────

  Future<void> addParticipant(String name) =>
      _commit(usecases.addParticipant(state.data, name));

  Future<void> renameParticipant(String id, String name) =>
      _commit(usecases.renameParticipant(state.data, id, name));

  Future<void> toggleParticipantActive(String id) =>
      _commit(usecases.toggleParticipantActive(state.data, id));

  Future<void> removeParticipant(String id) =>
      _commit(usecases.removeParticipant(state.data, id));
}
