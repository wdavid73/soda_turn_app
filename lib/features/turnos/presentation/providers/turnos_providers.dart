import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/turnos_local_datasource.dart';
import '../../data/repositories/turnos_repository_impl.dart';
import '../../domain/entities/turnos_stats.dart';
import '../../domain/repositories/turnos_repository.dart';
import '../../domain/services/fair_picker_service.dart';
import '../../domain/services/turnos_engine.dart';
import '../../domain/usecases/add_participant_usecase.dart';
import '../../domain/usecases/auto_assign_gaseosa_day_usecase.dart';
import '../../domain/usecases/auto_assign_weekly_vasos_usecase.dart';
import '../../domain/usecases/compute_stats_usecase.dart';
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
import 'turnos_view_model.dart';

/// Se sobreescribe en main() con la instancia real.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override en main()'),
);

final turnosLocalDatasourceProvider = Provider<TurnosLocalDatasource>(
  (ref) => TurnosLocalDatasourceImpl(ref.read(sharedPreferencesProvider)),
);

final turnosRepositoryProvider = Provider<TurnosRepository>(
  (ref) => TurnosRepositoryImpl(ref.read(turnosLocalDatasourceProvider)),
);

final fairPickerProvider = Provider<FairPickerService>(
  (ref) => FairPickerService(),
);

final turnosEngineProvider = Provider<TurnosEngine>(
  (ref) => TurnosEngine(ref.read(fairPickerProvider)),
);

final turnosUseCasesProvider = Provider<TurnosUseCases>((ref) {
  final repository = ref.read(turnosRepositoryProvider);
  final engine = ref.read(turnosEngineProvider);
  return TurnosUseCases(
    load: LoadTurnosUseCase(repository),
    save: SaveTurnosUseCase(repository),
    generateWeek: GenerateWeekUseCase(engine),
    autoAssignGaseosaDay: AutoAssignGaseosaDayUseCase(engine),
    autoAssignWeeklyVasos: AutoAssignWeeklyVasosUseCase(engine),
    manualSetGaseosa: ManualSetGaseosaUseCase(engine),
    manualSetWeeklyVasos: ManualSetWeeklyVasosUseCase(engine),
    setPresence: SetPresenceUseCase(engine),
    toggleDayLock: ToggleDayLockUseCase(engine),
    toggleWeekVasosLock: ToggleWeekVasosLockUseCase(engine),
    addParticipant: const AddParticipantUseCase(),
    renameParticipant: const RenameParticipantUseCase(),
    toggleParticipantActive: const ToggleParticipantActiveUseCase(),
    removeParticipant: const RemoveParticipantUseCase(),
  );
});

final turnosViewModelProvider =
    StateNotifierProvider<TurnosViewModel, TurnosUiState>(
      (ref) => TurnosViewModel(ref.read(turnosUseCasesProvider)),
    );

final computeStatsUseCaseProvider = Provider<ComputeStatsUseCase>(
  (ref) => ComputeStatsUseCase(ref.read(fairPickerProvider)),
);

/// Conteos históricos derivados del estado actual.
final turnosStatsProvider = Provider<TurnosStats>((ref) {
  final data = ref.watch(turnosViewModelProvider.select((s) => s.data));
  return ref.read(computeStatsUseCaseProvider)(data);
});
