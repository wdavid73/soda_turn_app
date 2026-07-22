import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/features/shifts/data/models/shifts_state_model.dart';
import 'package:turn_soda/features/shifts/domain/entities/assignment_entity.dart';
import 'package:turn_soda/features/shifts/domain/entities/generated_week_entity.dart';
import 'package:turn_soda/features/shifts/domain/entities/shifts_state_entity.dart';

void main() {
  test('round-trip entidad → json → entidad conserva todo', () {
    final original = ShiftsStateEntity.seed().copyWith(
      presenciaPorDia: {
        '2026-07-13': const ['wilson', 'pedro'],
      },
      asignaciones: {
        'gaseosa': {
          '2026-07-13': const AssignmentEntity(
            participanteId: 'pedro',
            locked: true,
            warning: 'algo',
          ),
        },
        'vasos': {
          '2026-07-13': const AssignmentEntity(participanteId: 'natalia'),
        },
      },
      semanas: {
        '2026-07-13': const GeneratedWeekEntity(
          monday: '2026-07-13',
          friday: '2026-07-17',
          estado: EstadoSemana.enCurso,
          participantes: [
            SemanaParticipanteEntity(
              participanteId: 'wilson',
              agregadoEn: '2026-07-13',
            ),
          ],
        ),
      },
    );

    final raw = jsonEncode(ShiftsStateModel.fromEntity(original).toJson());
    final restored = ShiftsStateModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    ).toEntity();

    expect(restored.participants, original.participants);
    expect(restored.productos, original.productos);
    expect(restored.condiciones, original.condiciones);
    expect(restored.asignaciones, original.asignaciones);
    expect(restored.presenciaPorDia, original.presenciaPorDia);
    expect(restored.exclusiones, original.exclusiones);
    expect(restored.semanas, original.semanas);
  });

  test('parsea el esquema genérico de productos', () {
    const raw = '''
    {
      "participants": [
        {"id": "wilson", "name": "Wilson", "active": true},
        {"id": "natalia", "name": "Natalia", "active": false}
      ],
      "productos": [
        {"id": "gaseosa", "nombre": "Gaseosa", "activo": true}
      ],
      "condiciones": {
        "gaseosa": {"frecuencia": "diario", "minPresentes": 4, "costoCop": 7000, "evitaRepetirPeriodoAnterior": true}
      },
      "asignaciones": {
        "gaseosa": {
          "2026-07-13": {"participanteId": "wilson", "locked": false, "warning": null}
        }
      },
      "presenciaPorDia": {
        "2026-07-13": ["wilson", "natalia"]
      },
      "exclusiones": [],
      "semanas": {
        "2026-07-13": {"friday": "2026-07-17", "estado": "planificada", "participantes": []}
      }
    }
    ''';

    final state = ShiftsStateModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    ).toEntity();

    expect(state.participants, hasLength(2));
    expect(state.participants[1].active, isFalse);
    expect(state.asignacionDe('gaseosa', '2026-07-13')!.participanteId, 'wilson');
    expect(state.condicionDe('gaseosa')!.minPresentes, 4);
    expect(state.semanaDe('2026-07-13')!.friday, '2026-07-17');
  });
}
