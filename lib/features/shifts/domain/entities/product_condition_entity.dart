/// Frecuencia con la que se reasigna un producto.
enum FrecuenciaProducto {
  /// Se re-evalúa cada día generable (ej. gaseosa).
  diario,

  /// Una sola persona para toda la semana (ej. vasos).
  semanalUnico,

  /// Una sola persona para todo el mes (reservado, no usado en el MVP).
  mensual,

  /// Alias de [diario] con fairness estricta (mismo pipeline; ver
  /// docs/02-reglas-negocio.md, regla 5b).
  rotativo,
}

/// Regla de negocio de un producto: cada cuánto se reasigna, mínimo de
/// presentes requerido, costo y si evita repetir a quien lo tuvo en el
/// periodo anterior (generaliza las reglas 1, 2, 6 y 9 del MVP).
class ProductConditionEntity {
  final String productoId;
  final FrecuenciaProducto frecuencia;
  final int minPresentes;
  final int? costoCop;
  final bool evitaRepetirPeriodoAnterior;

  const ProductConditionEntity({
    required this.productoId,
    required this.frecuencia,
    this.minPresentes = 1,
    this.costoCop,
    this.evitaRepetirPeriodoAnterior = false,
  });

  bool get esDiario =>
      frecuencia == FrecuenciaProducto.diario ||
      frecuencia == FrecuenciaProducto.rotativo;

  bool get esSemanalOMensual =>
      frecuencia == FrecuenciaProducto.semanalUnico ||
      frecuencia == FrecuenciaProducto.mensual;

  ProductConditionEntity copyWith({
    String? productoId,
    FrecuenciaProducto? frecuencia,
    int? minPresentes,
    int? costoCop,
    bool? evitaRepetirPeriodoAnterior,
  }) {
    return ProductConditionEntity(
      productoId: productoId ?? this.productoId,
      frecuencia: frecuencia ?? this.frecuencia,
      minPresentes: minPresentes ?? this.minPresentes,
      costoCop: costoCop ?? this.costoCop,
      evitaRepetirPeriodoAnterior:
          evitaRepetirPeriodoAnterior ?? this.evitaRepetirPeriodoAnterior,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductConditionEntity &&
          other.productoId == productoId &&
          other.frecuencia == frecuencia &&
          other.minPresentes == minPresentes &&
          other.costoCop == costoCop &&
          other.evitaRepetirPeriodoAnterior == evitaRepetirPeriodoAnterior;

  @override
  int get hashCode => Object.hash(
    productoId,
    frecuencia,
    minPresentes,
    costoCop,
    evitaRepetirPeriodoAnterior,
  );
}
