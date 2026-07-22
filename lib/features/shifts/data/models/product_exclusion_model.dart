import '../../domain/entities/product_exclusion_entity.dart';

/// Fila de la tabla `producto_exclusiones`.
class ProductExclusionModel {
  final String productoA;
  final String productoB;
  final ExclusionAlcance alcance;
  final ExclusionDureza dureza;

  const ProductExclusionModel({
    required this.productoA,
    required this.productoB,
    this.alcance = ExclusionAlcance.semana,
    this.dureza = ExclusionDureza.dura,
  });

  factory ProductExclusionModel.fromRow(Map<String, dynamic> row) => ProductExclusionModel(
    productoA: row['producto_a'] as String,
    productoB: row['producto_b'] as String,
    alcance: ExclusionAlcance.values.byName(row['alcance'] as String),
    dureza: ExclusionDureza.values.byName(row['dureza'] as String),
  );

  factory ProductExclusionModel.fromEntity(ProductExclusionEntity entity) =>
      ProductExclusionModel(
        productoA: entity.productoA,
        productoB: entity.productoB,
        alcance: entity.alcance,
        dureza: entity.dureza,
      );

  Map<String, dynamic> toRow() => {
    'producto_a': productoA,
    'producto_b': productoB,
    'alcance': alcance.name,
    'dureza': dureza.name,
  };

  ProductExclusionEntity toEntity() => ProductExclusionEntity(
    productoA: productoA,
    productoB: productoB,
    alcance: alcance,
    dureza: dureza,
  );
}
