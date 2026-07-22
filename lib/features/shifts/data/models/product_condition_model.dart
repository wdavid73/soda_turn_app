import '../../domain/entities/product_condition_entity.dart';

String frecuenciaToRow(FrecuenciaProducto f) {
  switch (f) {
    case FrecuenciaProducto.diario:
      return 'diario';
    case FrecuenciaProducto.semanalUnico:
      return 'semanal_unico';
    case FrecuenciaProducto.mensual:
      return 'mensual';
    case FrecuenciaProducto.rotativo:
      return 'rotativo';
  }
}

FrecuenciaProducto frecuenciaFromRow(String value) {
  switch (value) {
    case 'semanal_unico':
      return FrecuenciaProducto.semanalUnico;
    case 'mensual':
      return FrecuenciaProducto.mensual;
    case 'rotativo':
      return FrecuenciaProducto.rotativo;
    default:
      return FrecuenciaProducto.diario;
  }
}

/// Fila de la tabla `condicion_producto`.
class ProductConditionModel {
  final String productoId;
  final FrecuenciaProducto frecuencia;
  final int minPresentes;
  final int? costoCop;
  final bool evitaRepetirPeriodoAnterior;

  const ProductConditionModel({
    required this.productoId,
    required this.frecuencia,
    this.minPresentes = 1,
    this.costoCop,
    this.evitaRepetirPeriodoAnterior = false,
  });

  factory ProductConditionModel.fromRow(Map<String, dynamic> row) => ProductConditionModel(
    productoId: row['producto_id'] as String,
    frecuencia: frecuenciaFromRow(row['frecuencia'] as String),
    minPresentes: row['min_presentes'] as int? ?? 1,
    costoCop: row['costo_cop'] as int?,
    evitaRepetirPeriodoAnterior: row['evita_repetir_periodo_anterior'] as bool? ?? false,
  );

  factory ProductConditionModel.fromEntity(ProductConditionEntity entity) =>
      ProductConditionModel(
        productoId: entity.productoId,
        frecuencia: entity.frecuencia,
        minPresentes: entity.minPresentes,
        costoCop: entity.costoCop,
        evitaRepetirPeriodoAnterior: entity.evitaRepetirPeriodoAnterior,
      );

  Map<String, dynamic> toRow() => {
    'producto_id': productoId,
    'frecuencia': frecuenciaToRow(frecuencia),
    'min_presentes': minPresentes,
    'costo_cop': costoCop,
    'evita_repetir_periodo_anterior': evitaRepetirPeriodoAnterior,
  };

  ProductConditionEntity toEntity() => ProductConditionEntity(
    productoId: productoId,
    frecuencia: frecuencia,
    minPresentes: minPresentes,
    costoCop: costoCop,
    evitaRepetirPeriodoAnterior: evitaRepetirPeriodoAnterior,
  );
}
