import '../entities/turnos_state_entity.dart';
import '../entities/turnos_stats.dart';
import '../services/fair_picker_service.dart';

class ComputeStatsUseCase {
  final FairPickerService picker;

  const ComputeStatsUseCase(this.picker);

  TurnosStats call(TurnosStateEntity state) => picker.computeStats(state);
}
