/// A qué alcance aplica una exclusión entre dos productos.
enum ExclusionAlcance { semana, dia }

/// Si una exclusión es dura (nunca se viola en automático) o blanda
/// (se relaja con advertencia si no hay alternativa).
enum ExclusionDureza { dura, blanda }

/// Generaliza la regla 4 del MVP ("quien lleva los vasos no compra
/// gaseosa esa semana"): una fila expresa que [productoA] y [productoB]
/// no pueden recaer en la misma persona dentro de [alcance].
class ProductExclusionEntity {
  final String productoA;
  final String productoB;
  final ExclusionAlcance alcance;
  final ExclusionDureza dureza;

  const ProductExclusionEntity({
    required this.productoA,
    required this.productoB,
    this.alcance = ExclusionAlcance.semana,
    this.dureza = ExclusionDureza.dura,
  });

  bool involucra(String productoId) =>
      productoA == productoId || productoB == productoId;

  /// El otro producto de la pareja, dado uno de los dos.
  String otro(String productoId) =>
      productoA == productoId ? productoB : productoA;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductExclusionEntity &&
          other.productoA == productoA &&
          other.productoB == productoB &&
          other.alcance == alcance &&
          other.dureza == dureza;

  @override
  int get hashCode => Object.hash(productoA, productoB, alcance, dureza);
}
