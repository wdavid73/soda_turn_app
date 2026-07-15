import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

class AutoAssignWeeklyVasosUseCase {
  final TurnosEngine engine;

  const AutoAssignWeeklyVasosUseCase(this.engine);

  TurnosStateEntity call(TurnosStateEntity state, String mondayIso) =>
      engine.autoAssignWeeklyVasos(state, mondayIso);
}
