import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

class ToggleWeekVasosLockUseCase {
  final TurnosEngine engine;

  const ToggleWeekVasosLockUseCase(this.engine);

  TurnosStateEntity call(TurnosStateEntity state, String mondayIso) =>
      engine.toggleWeekVasosLock(state, mondayIso);
}
