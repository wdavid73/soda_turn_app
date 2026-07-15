import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

class AutoAssignGaseosaDayUseCase {
  final TurnosEngine engine;

  const AutoAssignGaseosaDayUseCase(this.engine);

  TurnosStateEntity call(TurnosStateEntity state, String dateIso) =>
      engine.autoAssignGaseosaDay(state, dateIso);
}
