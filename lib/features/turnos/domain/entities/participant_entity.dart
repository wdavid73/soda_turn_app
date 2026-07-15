/// Persona del grupo del almuerzo.
class ParticipantEntity {
  final String id;
  final String name;

  /// Inactivo = de vacaciones/ausente; no entra en presencia por defecto
  /// pero conserva su historial.
  final bool active;

  const ParticipantEntity({
    required this.id,
    required this.name,
    this.active = true,
  });

  ParticipantEntity copyWith({String? id, String? name, bool? active}) {
    return ParticipantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantEntity &&
          other.id == id &&
          other.name == name &&
          other.active == active;

  @override
  int get hashCode => Object.hash(id, name, active);
}
