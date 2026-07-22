import '../../domain/entities/product_entity.dart';

/// Fila de la tabla `productos`.
class ProductModel {
  final String id;
  final String nombre;
  final bool activo;

  const ProductModel({required this.id, required this.nombre, this.activo = true});

  factory ProductModel.fromRow(Map<String, dynamic> row) => ProductModel(
    id: row['id'] as String,
    nombre: row['nombre'] as String,
    activo: row['activo'] as bool? ?? true,
  );

  factory ProductModel.fromEntity(ProductEntity entity) =>
      ProductModel(id: entity.id, nombre: entity.nombre, activo: entity.activo);

  Map<String, dynamic> toRow() => {'id': id, 'nombre': nombre, 'activo': activo};

  ProductEntity toEntity() => ProductEntity(id: id, nombre: nombre, activo: activo);
}
