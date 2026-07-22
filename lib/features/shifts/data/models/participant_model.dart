import '../../domain/entities/participant_entity.dart';

class ParticipantModel {
  final String id;
  final String name;
  final bool active;

  const ParticipantModel({
    required this.id,
    required this.name,
    this.active = true,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      active: json['active'] as bool? ?? true,
    );
  }

  factory ParticipantModel.fromEntity(ParticipantEntity entity) {
    return ParticipantModel(
      id: entity.id,
      name: entity.name,
      active: entity.active,
    );
  }

  /// Fila de la tabla `participantes` (Supabase): columnas en español,
  /// distinto del blob JSON local (`id`/`name`/`active`, compatible con la
  /// web v2). Los soft-deleted (`eliminado_en` no nulo) igual se cargan:
  /// conservan su nombre para el historial, solo quedan con `active=false`.
  factory ParticipantModel.fromRow(Map<String, dynamic> row) {
    return ParticipantModel(
      id: row['id'] as String,
      name: row['nombre'] as String,
      active: row['activo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toRow() => {'id': id, 'nombre': name, 'activo': active};

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'active': active};

  ParticipantEntity toEntity() =>
      ParticipantEntity(id: id, name: name, active: active);
}
