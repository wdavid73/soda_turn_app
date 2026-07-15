import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

class SetPresenceUseCase {
  final TurnosEngine engine;

  const SetPresenceUseCase(this.engine);

  TurnosStateEntity call(
    TurnosStateEntity state,
    String dateIso,
    List<String> present,
  ) => engine.setPresence(state, dateIso, present);
}
