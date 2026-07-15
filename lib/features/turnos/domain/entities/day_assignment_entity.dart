const Object _unset = Object();

/// Registro de un día hábil: quiénes están presentes y quién compra gaseosa.
class DayAssignmentEntity {
  final List<String> present;
  final String? gaseosa;
  final bool locked;
  final String? warning;

  const DayAssignmentEntity({
    this.present = const [],
    this.gaseosa,
    this.locked = false,
    this.warning,
  });

  /// [gaseosa] y [warning] usan centinela para poder asignarles null.
  DayAssignmentEntity copyWith({
    List<String>? present,
    Object? gaseosa = _unset,
    bool? locked,
    Object? warning = _unset,
  }) {
    return DayAssignmentEntity(
      present: present ?? this.present,
      gaseosa: identical(gaseosa, _unset) ? this.gaseosa : gaseosa as String?,
      locked: locked ?? this.locked,
      warning: identical(warning, _unset) ? this.warning : warning as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayAssignmentEntity &&
          _listEquals(other.present, present) &&
          other.gaseosa == gaseosa &&
          other.locked == locked &&
          other.warning == warning;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(present), gaseosa, locked, warning);
}

bool _listEquals(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
