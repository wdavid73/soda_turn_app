import 'day_assignment_entity.dart';
import 'participant_entity.dart';
import 'weekly_vasos_entity.dart';

/// Agregado raíz del dominio: espejo del `state` de la web v2.
class TurnosStateEntity {
  final List<ParticipantEntity> participants;

  /// Un registro por día hábil; clave: fecha ISO `yyyy-MM-dd`.
  final Map<String, DayAssignmentEntity> assignments;

  /// Un registro por semana; clave: lunes ISO de esa semana.
  final Map<String, WeeklyVasosEntity> weeklyVasos;

  const TurnosStateEntity({
    this.participants = const [],
    this.assignments = const {},
    this.weeklyVasos = const {},
  });

  /// Participantes iniciales del grupo (editables desde la UI).
  factory TurnosStateEntity.seed() {
    return const TurnosStateEntity(
      participants: [
        ParticipantEntity(id: 'brayan-diaz', name: 'Brayan Díaz'),
        ParticipantEntity(id: 'brayan-valderrama', name: 'Brayan Valderrama'),
        ParticipantEntity(id: 'hector', name: 'Héctor'),
        ParticipantEntity(id: 'wilson', name: 'Wilson'),
        ParticipantEntity(id: 'pedro', name: 'Pedro'),
        ParticipantEntity(id: 'sebastian', name: 'Sebastián'),
        ParticipantEntity(id: 'walter', name: 'Walter'),
        ParticipantEntity(id: 'natalia', name: 'Natalia'),
      ],
    );
  }

  List<ParticipantEntity> get activeParticipants =>
      participants.where((p) => p.active).toList();

  List<String> get activeIds =>
      participants.where((p) => p.active).map((p) => p.id).toList();

  ParticipantEntity? participantById(String? id) {
    if (id == null) return null;
    for (final p in participants) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Nombre visible de un id (o el id si la persona fue eliminada).
  String nameOf(String? id) => participantById(id)?.name ?? (id ?? '—');

  TurnosStateEntity copyWith({
    List<ParticipantEntity>? participants,
    Map<String, DayAssignmentEntity>? assignments,
    Map<String, WeeklyVasosEntity>? weeklyVasos,
  }) {
    return TurnosStateEntity(
      participants: participants ?? this.participants,
      assignments: assignments ?? this.assignments,
      weeklyVasos: weeklyVasos ?? this.weeklyVasos,
    );
  }
}
