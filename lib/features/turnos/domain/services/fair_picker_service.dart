import 'dart:math';

import '../entities/turnos_state_entity.dart';
import '../entities/turnos_stats.dart';

/// Reparto justo (regla 5): siempre gana quien menos veces le ha tocado
/// en todo el historial; los empates se resuelven al azar.
class FairPickerService {
  final Random _rng;

  FairPickerService([Random? rng]) : _rng = rng ?? Random();

  /// Conteos históricos completos: gaseosa por día, vasos por semana.
  TurnosStats computeStats(TurnosStateEntity state) {
    final gaseosa = <String, int>{};
    final vasos = <String, int>{};
    for (final day in state.assignments.values) {
      final id = day.gaseosa;
      if (id != null) gaseosa[id] = (gaseosa[id] ?? 0) + 1;
    }
    for (final week in state.weeklyVasos.values) {
      final id = week.personId;
      if (id != null) vasos[id] = (vasos[id] ?? 0) + 1;
    }
    return TurnosStats(gaseosaCount: gaseosa, vasosCount: vasos);
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
