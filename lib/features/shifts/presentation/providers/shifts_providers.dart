import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../data/datasources/shifts_local_datasource.dart';
import '../../data/datasources/shifts_remote_datasource.dart';
import '../../data/repositories/shifts_repository_impl.dart';
import '../../data/repositories/shifts_supabase_repository.dart';
import '../../domain/entities/shifts_stats.dart';
import '../../domain/repositories/shifts_repository.dart';
import '../../domain/services/fair_picker_service.dart';
import '../../domain/services/shifts_engine.dart';
import '../../domain/usecases/add_participant_usecase.dart';
import '../../domain/usecases/add_week_participant_usecase.dart';
import '../../domain/usecases/auto_assign_product_usecase.dart';
import '../../domain/usecases/close_completed_weeks_usecase.dart';
import '../../domain/usecases/compute_stats_usecase.dart';
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
import 'shifts_view_model.dart';

/// Se sobreescribe en main() con la instancia real.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override en main()'),
);

final turnosLocalDatasourceProvider = Provider<ShiftsLocalDatasource>(
  (ref) => ShiftsLocalDatasourceImpl(ref.read(sharedPreferencesProvider)),
);

/// Fuente de verdad de persistencia: Supabase una vez que
/// `SupabaseConfig.isConfigured` (credenciales reales pegadas y app
/// inicializada en `main()`), local mientras tanto. Ver
/// docs/06-roadmap-supabase.md para la estrategia de migración de datos.
final turnosRepositoryProvider = Provider<ShiftsRepository>((ref) {
  final localDatasource = ref.read(turnosLocalDatasourceProvider);
  if (!SupabaseConfig.isConfigured) {
    return ShiftsRepositoryImpl(localDatasource);
  }
  final remoteDatasource = ShiftsRemoteDatasource(Supabase.instance.client);
  return ShiftsSupabaseRepository(remoteDatasource, localDatasource);
},
);

final fairPickerProvider = Provider<FairPickerService>(
  (ref) => FairPickerService(),
);

final turnosEngineProvider = Provider<ShiftsEngine>(
  (ref) => ShiftsEngine(ref.read(fairPickerProvider)),
);

final turnosUseCasesProvider = Provider<TurnosUseCases>((ref) {
  final repository = ref.read(turnosRepositoryProvider);
  final engine = ref.read(turnosEngineProvider);
  return TurnosUseCases(
    load: LoadTurnosUseCase(repository),
    save: SaveTurnosUseCase(repository),
    closeCompletedWeeks: CloseCompletedWeeksUseCase(repository),
    watchChanges: WatchShiftsChangesUseCase(repository),
    generateToday: GenerateTodayUseCase(engine),
    autoAssignProducto: AutoAssignProductoUseCase(engine),
    manualSetProducto: ManualSetProductoUseCase(engine),
    setPresence: SetPresenceUseCase(engine),
    toggleLock: ToggleLockUseCase(engine),
    configureWeek: ConfigureWeekUseCase(engine),
    addWeekParticipant: AddWeekParticipantUseCase(engine),
    removeWeekParticipant: RemoveWeekParticipantUseCase(engine),
    addParticipant: const AddParticipantUseCase(),
    renameParticipant: const RenameParticipantUseCase(),
    toggleParticipantActive: const ToggleParticipantActiveUseCase(),
    removeParticipant: const RemoveParticipantUseCase(),
  );
});

final turnosViewModelProvider =
    StateNotifierProvider<ShiftsViewModel, TurnosUiState>(
      (ref) => ShiftsViewModel(ref.read(turnosUseCasesProvider)),
    );

final computeStatsUseCaseProvider = Provider<ComputeStatsUseCase>(
  (ref) => ComputeStatsUseCase(ref.read(fairPickerProvider)),
);

/// Conteos históricos derivados del estado actual.
final turnosStatsProvider = Provider<ShiftsStats>((ref) {
  final data = ref.watch(turnosViewModelProvider.select((s) => s.data));
  return ref.read(computeStatsUseCaseProvider)(data);
});
