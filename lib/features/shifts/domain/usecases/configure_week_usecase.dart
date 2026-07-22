import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

/// Configura (o reconfigura) los participantes de una semana con
/// anticipación; no genera ninguna asignación todavía.
class ConfigureWeekUseCase {
  final ShiftsEngine engine;

  const ConfigureWeekUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String mondayIso,
    List<String> participantIds,
    String fechaConfiguracion,
  ) => engine.configureWeek(state, mondayIso, participantIds, fechaConfiguracion);
}
