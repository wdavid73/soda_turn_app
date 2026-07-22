import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

/// Reemplaza los antiguos `AutoAssignGaseosaDayUseCase`/
/// `AutoAssignWeeklyVasosUseCase`: asigna cualquier producto en cualquier
/// periodo (fecha ISO para productos diarios, lunes ISO para semanales).
class AutoAssignProductoUseCase {
  final ShiftsEngine engine;

  const AutoAssignProductoUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String productoId,
    String periodoId,
  ) => engine.autoAssignProducto(state, productoId, periodoId);
}
