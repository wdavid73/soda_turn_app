import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

/// Añade un participante a una semana ya configurada, a partir de
/// [fechaIso] (no retroactivo a días ya generados).
class AddWeekParticipantUseCase {
  final ShiftsEngine engine;

  const AddWeekParticipantUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String mondayIso,
    String participantId,
    String fechaIso,
  ) => engine.addWeekParticipant(state, mondayIso, participantId, fechaIso);
}
