import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

class SetPresenceUseCase {
  final ShiftsEngine engine;

  const SetPresenceUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String dateIso,
    List<String> present,
  ) => engine.setPresencia(state, dateIso, present);
}
