import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/features/turnos/data/models/turnos_state_model.dart';
import 'package:turn_soda/features/turnos/domain/entities/day_assignment_entity.dart';
import 'package:turn_soda/features/turnos/domain/entities/turnos_state_entity.dart';
import 'package:turn_soda/features/turnos/domain/entities/weekly_vasos_entity.dart';

void main() {
  test('round-trip entidad → json → entidad conserva todo', () {
    final original = TurnosStateEntity.seed().copyWith(
      assignments: {
        '2026-07-13': const DayAssignmentEntity(
          present: ['wilson', 'pedro'],
          gaseosa: 'pedro',
          locked: true,
          warning: 'algo',
        ),
      },
      weeklyVasos: {'2026-07-13': const WeeklyVasosEntity(personId: 'natalia')},
    );

    final raw = jsonEncode(TurnosStateModel.fromEntity(original).toJson());
    final restored = TurnosStateModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    ).toEntity();

    expect(restored.participants, original.participants);
    expect(restored.assignments, original.assignments);
    expect(restored.weeklyVasos, original.weeklyVasos);
  });

  test('parsea el esquema de respaldo de la web v2', () {
    const rawWeb = '''
    {
      "participants": [
        {"id": "wilson", "name": "Wilson", "active": true},
        {"id": "natalia", "name": "Natalia", "active": false}
      ],
      "assignments": {
        "2026-07-13": {
          "present": ["wilson", "natalia"],
          "gaseosa": "wilson",
          "locked": false,
          "warning": null
        }
      },
      "weeklyVasos": {
        "2026-07-13": {"personId": "natalia", "locked": false, "warning": null}
      }
    }
    ''';

    final state = TurnosStateModel.fromJson(
      jsonDecode(rawWeb) as Map<String, dynamic>,
    ).toEntity();

    expect(state.participants, hasLength(2));
    expect(state.participants[1].active, isFalse);
    expect(state.assignments['2026-07-13']!.gaseosa, 'wilson');
    expect(state.weeklyVasos['2026-07-13']!.personId, 'natalia');
  });
}
