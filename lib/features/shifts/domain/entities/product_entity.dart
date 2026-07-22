/// Algo que rota entre los participantes cada cierto periodo (gaseosa,
/// vasos, o cualquier producto nuevo que se configure).
class ProductEntity {
  final String id;
  final String nombre;
  final bool activo;

  const ProductEntity({
    required this.id,
    required this.nombre,
    this.activo = true,
  });

  ProductEntity copyWith({String? id, String? nombre, bool? activo}) {
    return ProductEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          other.id == id &&
          other.nombre == nombre &&
          other.activo == activo;

  @override
  int get hashCode => Object.hash(id, nombre, activo);
}
