const Object _unset = Object();

/// Registro semanal de vasos (clave: lunes ISO de la semana).
class WeeklyVasosEntity {
  final String? personId;
  final bool locked;
  final String? warning;

  const WeeklyVasosEntity({this.personId, this.locked = false, this.warning});

  WeeklyVasosEntity copyWith({
    Object? personId = _unset,
    bool? locked,
    Object? warning = _unset,
  }) {
    return WeeklyVasosEntity(
      personId: identical(personId, _unset)
          ? this.personId
          : personId as String?,
      locked: locked ?? this.locked,
      warning: identical(warning, _unset) ? this.warning : warning as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyVasosEntity &&
          other.personId == personId &&
          other.locked == locked &&
          other.warning == warning;

  @override
  int get hashCode => Object.hash(personId, locked, warning);
}
