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

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'active': active};

  ParticipantEntity toEntity() =>
      ParticipantEntity(id: id, name: name, active: active);
}
