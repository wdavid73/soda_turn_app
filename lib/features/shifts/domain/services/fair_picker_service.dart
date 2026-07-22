import 'dart:math';

import '../entities/shifts_state_entity.dart';
import '../entities/shifts_stats.dart';

/// Reparto justo (regla 5): siempre gana quien menos veces le ha tocado
/// en todo el historial, para el producto que se esté asignando; los
/// empates se resuelven al azar.
class FairPickerService {
  final Random _rng;

  FairPickerService([Random? rng]) : _rng = rng ?? Random();

  /// Conteos históricos completos por producto: cuántas veces le ha tocado
  /// a cada participante, sobre todas las asignaciones guardadas.
  ShiftsStats computeStats(ShiftsStateEntity state) {
    final counts = <String, Map<String, int>>{};
    for (final entry in state.asignaciones.entries) {
      final byParticipant = counts.putIfAbsent(entry.key, () => {});
      for (final asignacion in entry.value.values) {
        final id = asignacion.participanteId;
        if (id != null) byParticipant[id] = (byParticipant[id] ?? 0) + 1;
      }
    }
    return ShiftsStats(counts: counts);
  }

  /// Elige del [pool] a quien tenga el menor conteo en [counts].
  String? pickFair(List<String> pool, Map<String, int> counts) {
    if (pool.isEmpty) return null;
    var min = counts[pool.first] ?? 0;
    for (final id in pool.skip(1)) {
      final c = counts[id] ?? 0;
      if (c < min) min = c;
    }
    final best = pool.where((id) => (counts[id] ?? 0) == min).toList();
    return best[_rng.nextInt(best.length)];
  }
}
