import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

class ToggleDayLockUseCase {
  final TurnosEngine engine;

  const ToggleDayLockUseCase(this.engine);

  TurnosStateEntity call(TurnosStateEntity state, String dateIso) =>
      engine.toggleDayLock(state, dateIso);
}
