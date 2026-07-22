import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

/// Regla 8: la edición manual nunca se bloquea, solo advierte. Reemplaza
/// los antiguos `ManualSetGaseosaUseCase`/`ManualSetWeeklyVasosUseCase`.
class ManualSetProductoUseCase {
  final ShiftsEngine engine;

  const ManualSetProductoUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String productoId,
    String periodoId,
    String? participanteId,
  ) => engine.manualSetProducto(state, productoId, periodoId, participanteId);
}
