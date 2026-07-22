import '../../domain/entities/generated_week_entity.dart';

String estadoToRow(EstadoSemana e) {
  switch (e) {
    case EstadoSemana.planificada:
      return 'planificada';
    case EstadoSemana.enCurso:
      return 'en_curso';
    case EstadoSemana.completada:
      return 'completada';
  }
}

EstadoSemana estadoFromRow(String value) {
  switch (value) {
    case 'en_curso':
      return EstadoSemana.enCurso;
    case 'completada':
      return EstadoSemana.completada;
    default:
      return EstadoSemana.planificada;
  }
}

/// Fila de la tabla `semana_generada` (sin id de Supabase: el dominio la
/// identifica por `monday`, igual que el resto del agregado).
class GeneratedWeekModel {
  final String monday;
  final String friday;
  final EstadoSemana estado;

  const GeneratedWeekModel({
    required this.monday,
    required this.friday,
    this.estado = EstadoSemana.planificada,
  });

  factory GeneratedWeekModel.fromRow(Map<String, dynamic> row) => GeneratedWeekModel(
    monday: row['monday'] as String,
    friday: row['friday'] as String,
    estado: estadoFromRow(row['estado'] as String),
  );

  Map<String, dynamic> toRow() => {
    'monday': monday,
    'friday': friday,
    'estado': estadoToRow(estado),
  };
}

/// Fila de la tabla `semana_participantes`.
class SemanaParticipanteModel {
  final String participanteId;
  final String agregadoEn;
  final String? retiradoEn;

  const SemanaParticipanteModel({
    required this.participanteId,
    required this.agregadoEn,
    this.retiradoEn,
  });

  factory SemanaParticipanteModel.fromRow(Map<String, dynamic> row) =>
      SemanaParticipanteModel(
        participanteId: row['participante_id'] as String,
        agregadoEn: row['agregado_en'] as String,
        retiradoEn: row['retirado_en'] as String?,
      );

  factory SemanaParticipanteModel.fromEntity(SemanaParticipanteEntity entity) =>
      SemanaParticipanteModel(
        participanteId: entity.participanteId,
        agregadoEn: entity.agregadoEn,
        retiradoEn: entity.retiradoEn,
      );

  /// El `semana_id` (FK) se agrega en el datasource, que es quien conoce el
  /// uuid de `semana_generada` resuelto para el `monday` de esta semana.
  Map<String, dynamic> toRow() => {
    'participante_id': participanteId,
    'agregado_en': agregadoEn,
    'retirado_en': retiradoEn,
  };

  SemanaParticipanteEntity toEntity() => SemanaParticipanteEntity(
    participanteId: participanteId,
    agregadoEn: agregadoEn,
    retiradoEn: retiradoEn,
  );
}
