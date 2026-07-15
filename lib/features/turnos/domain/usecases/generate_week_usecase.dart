import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

/// Regla de orquestación: vasos primero, luego gaseosa día a día (v2).
class GenerateWeekUseCase {
  final TurnosEngine engine;

  const GenerateWeekUseCase(this.engine);

  TurnosStateEntity call(TurnosStateEntity state, String mondayIso) =>
      engine.generateWeek(state, mondayIso);
}
