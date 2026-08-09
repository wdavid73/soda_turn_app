import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/shifts_state_entity.dart';
import '../../domain/usecases/add_participant_usecase.dart';
import '../../domain/usecases/add_week_participant_usecase.dart';
import '../../domain/usecases/auto_assign_product_usecase.dart';
import '../../domain/usecases/close_completed_weeks_usecase.dart';
import '../../domain/usecases/configure_week_usecase.dart';
import '../../domain/usecases/generate_today_usecase.dart';
import '../../domain/usecases/load_shifts_usecase.dart';
import '../../domain/usecases/manual_set_product_usecase.dart';
import '../../domain/usecases/remove_participant_usecase.dart';
import '../../domain/usecases/remove_week_participant_usecase.dart';
import '../../domain/usecases/rename_participant_usecase.dart';
import '../../domain/usecases/save_shifts_usecase.dart';
import '../../domain/usecases/set_presence_usecase.dart';
import '../../domain/usecases/toggle_lock_usecase.dart';
import '../../domain/usecases/toggle_participant_active_usecase.dart';
import '../../domain/usecases/watch_shifts_changes_usecase.dart';

/// Bundle de usecases para no inflar el constructor del ViewModel.
class TurnosUseCases {
  final LoadTurnosUseCase load;
  final SaveTurnosUseCase save;
  final CloseCompletedWeeksUseCase closeCompletedWeeks;
  final WatchShiftsChangesUseCase watchChanges;
  final GenerateTodayUseCase generateToday;
  final AutoAssignProductoUseCase autoAssignProducto;
  final ManualSetProductoUseCase manualSetProducto;
  final SetPresenceUseCase setPresence;
  final ToggleLockUseCase toggleLock;
  final ConfigureWeekUseCase configureWeek;
  final AddWeekParticipantUseCase addWeekParticipant;
  final RemoveWeekParticipantUseCase removeWeekParticipant;
  final AddParticipantUseCase addParticipant;
  final RenameParticipantUseCase renameParticipant;
  final ToggleParticipantActiveUseCase toggleParticipantActive;
  final RemoveParticipantUseCase removeParticipant;

  const TurnosUseCases({
    required this.load,
    required this.save,
    required this.closeCompletedWeeks,
    required this.watchChanges,
    required this.generateToday,
    required this.autoAssignProducto,
    required this.manualSetProducto,
    required this.setPresence,
    required this.toggleLock,
    required this.configureWeek,
    required this.addWeekParticipant,
    required this.removeWeekParticipant,
    required this.addParticipant,
    required this.renameParticipant,
    required this.toggleParticipantActive,
    required this.removeParticipant,
  });
}

const Object _unset = Object();

class TurnosUiState {
  final bool loading;
  final ShiftsStateEntity data;

  /// Lunes ISO de la semana visible en la pantalla "Semana".
  final String selectedMonday;
  final String? error;

  const TurnosUiState({
    this.loading = true,
    this.data = const ShiftsStateEntity(),
    required this.selectedMonday,
    this.error,
  });

  TurnosUiState copyWith({
    bool? loading,
    ShiftsStateEntity? data,
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

class ShiftsViewModel extends StateNotifier<TurnosUiState> {
  final TurnosUseCases usecases;

  static const _changesDebounce = Duration(milliseconds: 400);

  StreamSubscription<void>? _changesSub;
  Timer? _debounceTimer;

  /// Cantidad de `_commit` en curso. Mientras sea > 0, `_reload` no debe
  /// aplicar su resultado: el propio `save()` dispara eventos Realtime en
  /// las mismas tablas que escribe, y un `load()` que llega antes de que
  /// el commit termine devuelve datos desactualizados que pisarían la
  /// edición optimista recién aplicada (bug: había que tocar 2-3 veces
  /// para que una selección manual quedara guardada).
  int _pendingCommits = 0;

  ShiftsViewModel(this.usecases)
    : super(
        TurnosUiState(
          selectedMonday: AppDateUtils.activeMondayIso(DateTime.now()),
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    // Best-effort: si falla, no debe bloquear la carga normal (ver
    // CloseCompletedWeeksUseCase).
    await usecases.closeCompletedWeeks(AppDateUtils.toIso(DateTime.now()));
    await _reload();
    _subscribeToChanges();
  }

  Future<void> _reload() async {
    if (_pendingCommits > 0) return;
    final result = await usecases.load();
    if (_pendingCommits > 0) return;
    result.fold(
      (failure) =>
          state = state.copyWith(loading: false, error: failure.message),
      (data) => state = state.copyWith(loading: false, data: data, error: null),
    );
  }

  /// Recarga el estado cuando otro dispositivo cambia la semana activa
  /// (ver `WatchShiftsChangesUseCase`), con debounce para no disparar un
  /// `load()` por cada fila si llegan varios cambios seguidos.
  void _subscribeToChanges() {
    _changesSub = usecases.watchChanges().listen((_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_changesDebounce, _reload);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _changesSub?.cancel();
    super.dispose();
  }

  /// Aplica una mutación pura del estado de dominio y la persiste.
  Future<void> _commit(ShiftsStateEntity next) async {
    state = state.copyWith(data: next);
    _pendingCommits++;
    try {
      final result = await usecases.save(next);
      result.fold(
        (failure) => state = state.copyWith(error: failure.message),
        (_) {},
      );
    } finally {
      _pendingCommits--;
    }
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

  /// Salta directamente a la semana de [mondayIso] (ej. "Ver semana" desde
  /// el historial).
  void selectMonday(String mondayIso) =>
      state = state.copyWith(selectedMonday: mondayIso);

  // ── Generación y asignaciones ───────────────────────────────────────────

  /// Genera únicamente los periodos pendientes hasta hoy (nunca semanas ni
  /// días futuros); ver `ShiftsEngine.generateToday`.
  Future<void> generateToday() => _commit(
    usecases.generateToday(
      state.data,
      state.selectedMonday,
      AppDateUtils.toIso(DateTime.now()),
    ),
  );

  Future<void> autoAssignProducto(String productoId, String periodoId) =>
      _commit(usecases.autoAssignProducto(state.data, productoId, periodoId));

  Future<void> setProducto(
    String productoId,
    String periodoId,
    String? participanteId,
  ) => _commit(
    usecases.manualSetProducto(state.data, productoId, periodoId, participanteId),
  );

  Future<void> setPresence(String dateIso, List<String> present) =>
      _commit(usecases.setPresence(state.data, dateIso, present));

  Future<void> toggleLock(String productoId, String periodoId) =>
      _commit(usecases.toggleLock(state.data, productoId, periodoId));

  // ── Configuración de semana ──────────────────────────────────────────────

  Future<void> configureWeek(List<String> participantIds) => _commit(
    usecases.configureWeek(
      state.data,
      state.selectedMonday,
      participantIds,
      AppDateUtils.toIso(DateTime.now()),
    ),
  );

  Future<void> addWeekParticipant(String participantId) => _commit(
    usecases.addWeekParticipant(
      state.data,
      state.selectedMonday,
      participantId,
      AppDateUtils.toIso(DateTime.now()),
    ),
  );

  Future<void> removeWeekParticipant(String participantId) => _commit(
    usecases.removeWeekParticipant(
      state.data,
      state.selectedMonday,
      participantId,
      AppDateUtils.toIso(DateTime.now()),
    ),
  );

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
