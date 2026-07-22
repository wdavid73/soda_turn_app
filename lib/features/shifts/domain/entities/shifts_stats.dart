import 'product_condition_entity.dart';

/// Conteos históricos genéricos: por producto, cuántas veces le ha tocado
/// a cada participante en TODO el historial guardado.
class ShiftsStats {
  /// Clave externa: `productoId`. Clave interna: `participanteId`.
  final Map<String, Map<String, int>> counts;

  const ShiftsStats({this.counts = const {}});

  int countOf(String productoId, String participanteId) =>
      counts[productoId]?[participanteId] ?? 0;

  int totalOf(String participanteId) => counts.values.fold(
    0,
    (sum, byParticipant) => sum + (byParticipant[participanteId] ?? 0),
  );

  int totalDe(String productoId) =>
      (counts[productoId] ?? const {}).values.fold(0, (a, b) => a + b);

  /// Gasto aproximado de un participante, sumando `count * costoCop` de
  /// cada producto que tenga costo definido (regla 9 generalizada).
  int gastoCopOf(
    String participanteId,
    Map<String, ProductConditionEntity> condiciones,
  ) {
    var total = 0;
    for (final entry in counts.entries) {
      final costo = condiciones[entry.key]?.costoCop;
      if (costo == null) continue;
      total += (entry.value[participanteId] ?? 0) * costo;
    }
    return total;
  }

  int totalGastoCop(Map<String, ProductConditionEntity> condiciones) {
    var total = 0;
    for (final entry in counts.entries) {
      final costo = condiciones[entry.key]?.costoCop;
      if (costo == null) continue;
      total += entry.value.values.fold(0, (a, b) => a + b) * costo;
    }
    return total;
  }
}
