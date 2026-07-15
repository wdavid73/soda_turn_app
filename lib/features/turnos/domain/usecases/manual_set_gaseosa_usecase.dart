import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

/// Regla 8: la edición manual nunca se bloquea, solo advierte.
class ManualSetGaseosaUseCase {
  final TurnosEngine engine;

  const ManualSetGaseosaUseCase(this.engine);

  TurnosStateEntity call(
    TurnosStateEntity state,
    String dateIso,
    String? personId,
  ) => engine.manualSetGaseosa(state, dateIso, personId);
}
