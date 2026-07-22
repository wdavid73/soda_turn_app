import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

/// Reemplaza `ToggleDayLockUseCase`/`ToggleWeekVasosLockUseCase`: bloquea o
/// desbloquea la asignación de cualquier producto en cualquier periodo.
class ToggleLockUseCase {
  final ShiftsEngine engine;

  const ToggleLockUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String productoId,
    String periodoId,
  ) => engine.toggleLock(state, productoId, periodoId);
}
