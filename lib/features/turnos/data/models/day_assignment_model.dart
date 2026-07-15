import '../../domain/entities/day_assignment_entity.dart';

class DayAssignmentModel {
  final List<String> present;
  final String? gaseosa;
  final bool locked;
  final String? warning;

  const DayAssignmentModel({
    this.present = const [],
    this.gaseosa,
    this.locked = false,
    this.warning,
  });

  factory DayAssignmentModel.fromJson(Map<String, dynamic> json) {
    return DayAssignmentModel(
      present: (json['present'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      gaseosa: json['gaseosa']?.toString(),
      locked: json['locked'] as bool? ?? false,
      warning: json['warning']?.toString(),
    );
  }

  factory DayAssignmentModel.fromEntity(DayAssignmentEntity entity) {
    return DayAssignmentModel(
      present: entity.present,
      gaseosa: entity.gaseosa,
      locked: entity.locked,
      warning: entity.warning,
    );
  }

  Map<String, dynamic> toJson() => {
    'present': present,
    'gaseosa': gaseosa,
    'locked': locked,
    'warning': warning,
  };

  DayAssignmentEntity toEntity() => DayAssignmentEntity(
    present: present,
    gaseosa: gaseosa,
    locked: locked,
    warning: warning,
  );
}
