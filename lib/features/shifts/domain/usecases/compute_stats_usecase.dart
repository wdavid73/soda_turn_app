import '../entities/shifts_state_entity.dart';
import '../entities/shifts_stats.dart';
import '../services/fair_picker_service.dart';

class ComputeStatsUseCase {
  final FairPickerService picker;

  const ComputeStatsUseCase(this.picker);

  ShiftsStats call(ShiftsStateEntity state) => picker.computeStats(state);
}
