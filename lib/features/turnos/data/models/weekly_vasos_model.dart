import '../../domain/entities/weekly_vasos_entity.dart';

class WeeklyVasosModel {
  final String? personId;
  final bool locked;
  final String? warning;

  const WeeklyVasosModel({this.personId, this.locked = false, this.warning});

  factory WeeklyVasosModel.fromJson(Map<String, dynamic> json) {
    return WeeklyVasosModel(
      personId: json['personId']?.toString(),
      locked: json['locked'] as bool? ?? false,
      warning: json['warning']?.toString(),
    );
  }

  factory WeeklyVasosModel.fromEntity(WeeklyVasosEntity entity) {
    return WeeklyVasosModel(
      personId: entity.personId,
      locked: entity.locked,
      warning: entity.warning,
    );
  }

  Map<String, dynamic> toJson() => {
    'personId': personId,
    'locked': locked,
    'warning': warning,
  };

  WeeklyVasosEntity toEntity() =>
      WeeklyVasosEntity(personId: personId, locked: locked, warning: warning);
}
