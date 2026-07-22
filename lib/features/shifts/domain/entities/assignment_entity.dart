const Object _unset = Object();

/// Asignación de UN producto en UN periodo. La clave de periodo (fecha ISO
/// o lunes ISO) vive en el mapa contenedor (`ShiftsStateEntity.asignaciones`),
/// no aquí. Generaliza `DayAssignmentEntity` y `WeeklyVasosEntity` del MVP
/// hardcodeado en un solo tipo, ya que ambos guardaban exactamente lo mismo.
class AssignmentEntity {
  final String? participanteId;
  final bool locked;
  final String? warning;

  const AssignmentEntity({this.participanteId, this.locked = false, this.warning});

  /// [participanteId] y [warning] usan centinela para poder asignarles null.
  AssignmentEntity copyWith({
    Object? participanteId = _unset,
    bool? locked,
    Object? warning = _unset,
  }) {
    return AssignmentEntity(
      participanteId: identical(participanteId, _unset)
          ? this.participanteId
          : participanteId as String?,
      locked: locked ?? this.locked,
      warning: identical(warning, _unset) ? this.warning : warning as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentEntity &&
          other.participanteId == participanteId &&
          other.locked == locked &&
          other.warning == warning;

  @override
  int get hashCode => Object.hash(participanteId, locked, warning);
}
