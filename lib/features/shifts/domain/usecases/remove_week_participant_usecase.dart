import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

/// Retira a un participante de una semana ya configurada desde
/// [fechaIso] en adelante; su historial previo en esa semana se conserva.
class RemoveWeekParticipantUseCase {
  final ShiftsEngine engine;

  const RemoveWeekParticipantUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String mondayIso,
    String participantId,
    String fechaIso,
  ) => engine.removeWeekParticipant(state, mondayIso, participantId, fechaIso);
}
