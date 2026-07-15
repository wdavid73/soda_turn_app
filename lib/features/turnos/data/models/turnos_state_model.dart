import '../../domain/entities/turnos_state_entity.dart';
import 'day_assignment_model.dart';
import 'participant_model.dart';
import 'weekly_vasos_model.dart';

/// Estado completo serializado. El JSON es compatible con el respaldo de la
/// web v2 (clave `almuerzo-turnos-v2`), para poder importar/exportar entre
/// ambas versiones y migrar a Supabase sin cambiar el esquema.
class TurnosStateModel {
  final List<ParticipantModel> participants;
  final Map<String, DayAssignmentModel> assignments;
  final Map<String, WeeklyVasosModel> weeklyVasos;

  const TurnosStateModel({
    this.participants = const [],
    this.assignments = const {},
    this.weeklyVasos = const {},
  });

  factory TurnosStateModel.fromJson(Map<String, dynamic> json) {
    return TurnosStateModel(
      participants: (json['participants'] as List? ?? const [])
          .map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      assignments: (json['assignments'] as Map<String, dynamic>? ?? const {})
          .map(
            (key, value) => MapEntry(
              key,
              DayAssignmentModel.fromJson(value as Map<String, dynamic>),
            ),
          ),
      weeklyVasos: (json['weeklyVasos'] as Map<String, dynamic>? ?? const {})
          .map(
            (key, value) => MapEntry(
              key,
              WeeklyVasosModel.fromJson(value as Map<String, dynamic>),
            ),
          ),
    );
  }

  factory TurnosStateModel.fromEntity(TurnosStateEntity entity) {
    return TurnosStateModel(
      participants: entity.participants
          .map(ParticipantModel.fromEntity)
          .toList(),
      assignments: entity.assignments.map(
        (key, value) => MapEntry(key, DayAssignmentModel.fromEntity(value)),
      ),
      weeklyVasos: entity.weeklyVasos.map(
        (key, value) => MapEntry(key, WeeklyVasosModel.fromEntity(value)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'participants': participants.map((p) => p.toJson()).toList(),
    'assignments': assignments.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'weeklyVasos': weeklyVasos.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
  };

  TurnosStateEntity toEntity() => TurnosStateEntity(
    participants: participants.map((p) => p.toEntity()).toList(),
    assignments: assignments.map(
      (key, value) => MapEntry(key, value.toEntity()),
    ),
    weeklyVasos: weeklyVasos.map(
      (key, value) => MapEntry(key, value.toEntity()),
    ),
  );
}
