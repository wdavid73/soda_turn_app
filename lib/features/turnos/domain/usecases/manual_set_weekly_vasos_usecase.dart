import '../entities/turnos_state_entity.dart';
import '../services/turnos_engine.dart';

class ManualSetWeeklyVasosUseCase {
  final TurnosEngine engine;

  const ManualSetWeeklyVasosUseCase(this.engine);

  TurnosStateEntity call(
    TurnosStateEntity state,
    String mondayIso,
    String? personId,
  ) => engine.manualSetWeeklyVasos(state, mondayIso, personId);
}
