import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/core/utils/app_date_utils.dart';
import 'package:turn_soda/features/turnos/domain/entities/day_assignment_entity.dart';
import 'package:turn_soda/features/turnos/domain/entities/participant_entity.dart';
import 'package:turn_soda/features/turnos/domain/entities/turnos_state_entity.dart';
import 'package:turn_soda/features/turnos/domain/entities/weekly_vasos_entity.dart';
import 'package:turn_soda/features/turnos/domain/services/fair_picker_service.dart';
import 'package:turn_soda/features/turnos/domain/services/turnos_engine.dart';
import 'package:turn_soda/features/turnos/domain/usecases/add_participant_usecase.dart';

const monday = '2026-07-13';
const prevMonday = '2026-07-06';
const prevFriday = '2026-07-10';

TurnosEngine makeEngine([int seed = 42]) =>
    TurnosEngine(FairPickerService(Random(seed)));

List<String> weekBuyers(TurnosStateEntity s, String mondayIso) => [
  for (final day in AppDateUtils.weekDays(mondayIso))
    if (s.assignments[day]?.gaseosa != null) s.assignments[day]!.gaseosa!,
];

void main() {
  group('generateWeek (flujo automático)', () {
    test('asigna vasos y los 5 días de gaseosa sin advertencias', () {
      final engine = makeEngine();
      final s = engine.generateWeek(TurnosStateEntity.seed(), monday);

      expect(s.weeklyVasos[monday]?.personId, isNotNull);
      final buyers = weekBuyers(s, monday);
      expect(buyers, hasLength(5));
      for (final day in AppDateUtils.weekDays(monday)) {
        expect(s.assignments[day]?.warning, isNull);
      }
    });

    test('regla 4 (dura): quien lleva los vasos nunca compra gaseosa', () {
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = engine.generateWeek(TurnosStateEntity.seed(), monday);
        final vasosId = s.weeklyVasos[monday]!.personId;
        expect(weekBuyers(s, monday), isNot(contains(vasosId)));
      }
    });

    test('regla 2: nadie repite gaseosa dos días hábiles seguidos', () {
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = engine.generateWeek(TurnosStateEntity.seed(), monday);
        final days = AppDateUtils.weekDays(monday);
        for (var i = 1; i < days.length; i++) {
          expect(
            s.assignments[days[i]]!.gaseosa,
            isNot(s.assignments[days[i - 1]]!.gaseosa),
          );
        }
      }
    });

    test(
      'regla 2 cruza el fin de semana: el del viernes no repite el lunes',
      () {
        final base = TurnosStateEntity.seed().copyWith(
          assignments: {
            prevFriday: const DayAssignmentEntity(
              present: ['pedro', 'wilson', 'hector', 'natalia'],
              gaseosa: 'pedro',
            ),
          },
        );
        for (var seed = 0; seed < 20; seed++) {
          final engine = makeEngine(seed);
          final s = engine.generateWeek(base, monday);
          expect(s.assignments[monday]!.gaseosa, isNot('pedro'));
        }
      },
    );

    test('regla 1: con menos de 4 presentes el día queda sin asignar', () {
      final engine = makeEngine();
      var s = engine.ensureWeekDefaults(TurnosStateEntity.seed(), monday);
      s = engine.setPresence(s, monday, ['wilson', 'pedro', 'natalia']);
      s = engine.generateWeek(s, monday);

      expect(s.assignments[monday]!.gaseosa, isNull);
      expect(s.assignments[monday]!.warning, TurnosEngine.warnMinPresentes);
      // Los demás días sí quedan asignados.
      expect(weekBuyers(s, monday), hasLength(4));
    });

    test('regla 5: fairness — quien más ha comprado no vuelve a salir', () {
      // Wilson acumula 5 gaseosas históricas; el resto está en 0.
      final history = <String, DayAssignmentEntity>{
        for (final day in AppDateUtils.weekDays(prevMonday))
          day: const DayAssignmentEntity(
            present: ['wilson', 'pedro', 'hector', 'natalia'],
            gaseosa: 'wilson',
          ),
      };
      final base = TurnosStateEntity.seed().copyWith(assignments: history);
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = engine.generateWeek(base, monday);
        expect(weekBuyers(s, monday), isNot(contains('wilson')));
      }
    });

    test('regla 6: no repite la persona de vasos de la semana anterior', () {
      final base = TurnosStateEntity.seed().copyWith(
        weeklyVasos: {prevMonday: const WeeklyVasosEntity(personId: 'natalia')},
      );
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = engine.generateWeek(base, monday);
        expect(s.weeklyVasos[monday]!.personId, isNot('natalia'));
      }
    });

    test('regla 6 se relaja con advertencia si no hay alternativa', () {
      final engine = makeEngine();
      final base = TurnosStateEntity.seed().copyWith(
        participants: const [ParticipantEntity(id: 'wilson', name: 'Wilson')],
        weeklyVasos: {prevMonday: const WeeklyVasosEntity(personId: 'wilson')},
      );
      final s = engine.pickWeeklyVasos(base, monday);
      expect(s.weeklyVasos[monday]!.personId, 'wilson');
      expect(
        s.weeklyVasos[monday]!.warning,
        TurnosEngine.warnRepiteVasosSemana,
      );
    });

    test('regla 7: un día bloqueado no se sobreescribe al generar', () {
      final engine = makeEngine();
      var s = engine.ensureWeekDefaults(TurnosStateEntity.seed(), monday);
      s = engine.manualSetGaseosa(s, monday, 'pedro');
      s = engine.toggleDayLock(s, monday);
      s = engine.generateWeek(s, monday);

      expect(s.assignments[monday]!.gaseosa, 'pedro');
      expect(s.assignments[monday]!.locked, isTrue);
      // Y el vasos elegido no puede ser pedro (regla 4 contra día bloqueado).
      expect(s.weeklyVasos[monday]!.personId, isNot('pedro'));
    });

    test('regla 7: la semana de vasos bloqueada no se sobreescribe', () {
      final engine = makeEngine();
      var s = engine.manualSetWeeklyVasos(
        TurnosStateEntity.seed(),
        monday,
        'natalia',
      );
      s = engine.toggleWeekVasosLock(s, monday);
      s = engine.generateWeek(s, monday);

      expect(s.weeklyVasos[monday]!.personId, 'natalia');
      expect(weekBuyers(s, monday), isNot(contains('natalia')));
    });
  });

  group('edición manual (regla 8)', () {
    test('asignar al de los vasos advierte pero no bloquea', () {
      final engine = makeEngine();
      var s = engine.generateWeek(TurnosStateEntity.seed(), monday);
      final vasosId = s.weeklyVasos[monday]!.personId!;
      s = engine.manualSetGaseosa(s, monday, vasosId);

      expect(s.assignments[monday]!.gaseosa, vasosId);
      expect(s.assignments[monday]!.warning, contains('vasos'));
    });

    test('repetir al comprador del día anterior advierte', () {
      final engine = makeEngine();
      var s = engine.generateWeek(TurnosStateEntity.seed(), monday);
      final mondayBuyer = s.assignments[monday]!.gaseosa!;
      s = engine.manualSetGaseosa(s, '2026-07-14', mondayBuyer);

      expect(s.assignments['2026-07-14']!.warning, contains('anterior'));
    });

    test('fijar vasos manual libera y reasigna los días de esa persona', () {
      final engine = makeEngine();
      var s = engine.generateWeek(TurnosStateEntity.seed(), monday);
      final mondayBuyer = s.assignments[monday]!.gaseosa!;
      s = engine.manualSetWeeklyVasos(s, monday, mondayBuyer);

      expect(s.weeklyVasos[monday]!.personId, mondayBuyer);
      expect(s.assignments[monday]!.gaseosa, isNot(mondayBuyer));
      expect(s.assignments[monday]!.gaseosa, isNotNull);
    });

    test('fijar vasos manual sobre un día bloqueado solo advierte', () {
      final engine = makeEngine();
      var s = engine.ensureWeekDefaults(TurnosStateEntity.seed(), monday);
      s = engine.manualSetGaseosa(s, monday, 'pedro');
      s = engine.toggleDayLock(s, monday);
      s = engine.manualSetWeeklyVasos(s, monday, 'pedro');

      expect(s.assignments[monday]!.gaseosa, 'pedro');
      expect(
        s.assignments[monday]!.warning,
        TurnosEngine.warnConflictoVasosDiaBloqueado,
      );
    });

    test('quitar de presentes al asignado deja advertencia', () {
      final engine = makeEngine();
      var s = engine.generateWeek(TurnosStateEntity.seed(), monday);
      final buyer = s.assignments[monday]!.gaseosa!;
      final present = s.assignments[monday]!.present
          .where((id) => id != buyer)
          .toList();
      s = engine.setPresence(s, monday, present);

      expect(s.assignments[monday]!.warning, contains('presente'));
    });
  });

  group('participantes', () {
    test('agregar nombre duplicado genera id único', () {
      const usecase = AddParticipantUseCase();
      final s = usecase(TurnosStateEntity.seed(), 'Pedro');
      expect(s.participants.map((p) => p.id), contains('pedro-2'));
    });

    test('la presencia por defecto solo incluye activos', () {
      final engine = makeEngine();
      final base = TurnosStateEntity.seed().copyWith(
        participants: [
          for (final p in TurnosStateEntity.seed().participants)
            if (p.id == 'walter') p.copyWith(active: false) else p,
        ],
      );
      final s = engine.ensureWeekDefaults(base, monday);
      expect(s.assignments[monday]!.present, isNot(contains('walter')));
      expect(s.assignments[monday]!.present, hasLength(7));
    });
  });

  group('FairPickerService', () {
    test('pickFair elige siempre al de menor conteo', () {
      final picker = FairPickerService(Random(1));
      final pick = picker.pickFair(['a', 'b', 'c'], {'a': 2, 'b': 0, 'c': 1});
      expect(pick, 'b');
    });

    test('pickFair con pool vacío devuelve null', () {
      final picker = FairPickerService(Random(1));
      expect(picker.pickFair([], {}), isNull);
    });
  });
}
