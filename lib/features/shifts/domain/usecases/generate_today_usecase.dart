import '../entities/shifts_state_entity.dart';
import '../services/shifts_engine.dart';

/// Reemplaza `GenerateWeekUseCase`: nunca genera una semana completa por
/// adelantado. Solo calcula los productos semanales pendientes (una vez) y
/// los productos diarios de los días generables hasta [todayIso] (con
/// catch-up de días previos sin asignar; nunca días futuros).
class GenerateTodayUseCase {
  final ShiftsEngine engine;

  const GenerateTodayUseCase(this.engine);

  ShiftsStateEntity call(
    ShiftsStateEntity state,
    String mondayIso,
    String todayIso,
  ) => engine.generateToday(state, mondayIso, todayIso);
}
