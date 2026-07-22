import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/core/utils/app_date_utils.dart';
import 'package:turn_soda/features/shifts/domain/entities/assignment_entity.dart';
import 'package:turn_soda/features/shifts/domain/entities/participant_entity.dart';
import 'package:turn_soda/features/shifts/domain/entities/shifts_state_entity.dart';
import 'package:turn_soda/features/shifts/domain/services/fair_picker_service.dart';
import 'package:turn_soda/features/shifts/domain/services/shifts_engine.dart';
import 'package:turn_soda/features/shifts/domain/usecases/add_participant_usecase.dart';

const monday = '2026-07-13';
const friday = '2026-07-17';
const prevMonday = '2026-07-06';
const prevFriday = '2026-07-10';

ShiftsEngine makeEngine([int seed = 42]) =>
    ShiftsEngine(FairPickerService(Random(seed)));

/// Genera toda la semana de una vez (equivalente al `generateWeek` del MVP
/// v1): se logra pasando el viernes como "hoy" para que el catch-up de
/// `generateToday` procese los 5 días generables.
ShiftsStateEntity generateWholeWeek(
  ShiftsEngine engine,
  ShiftsStateEntity state,
  String mondayIso,
) => engine.generateToday(state, mondayIso, friday);

List<String> weekBuyers(ShiftsStateEntity s, String mondayIso) => [
  for (final day in AppDateUtils.weekDays(mondayIso))
    if (s.asignacionDe('gaseosa', day)?.participanteId != null)
      s.asignacionDe('gaseosa', day)!.participanteId!,
];

void main() {
  group('generateToday (flujo automático, semana completa)', () {
    test('asigna vasos y los 5 días de gaseosa sin advertencias', () {
      final engine = makeEngine();
      final s = generateWholeWeek(engine, ShiftsStateEntity.seed(), monday);

      expect(s.asignacionDe('vasos', monday)?.participanteId, isNotNull);
      final buyers = weekBuyers(s, monday);
      expect(buyers, hasLength(5));
      for (final day in AppDateUtils.weekDays(monday)) {
        expect(s.asignacionDe('gaseosa', day)?.warning, isNull);
      }
    });

    test('regla 4 (dura): quien lleva los vasos nunca compra gaseosa', () {
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = generateWholeWeek(engine, ShiftsStateEntity.seed(), monday);
        final vasosId = s.asignacionDe('vasos', monday)!.participanteId;
        expect(weekBuyers(s, monday), isNot(contains(vasosId)));
      }
    });

    test('regla 2: nadie repite gaseosa dos días hábiles seguidos', () {
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = generateWholeWeek(engine, ShiftsStateEntity.seed(), monday);
        final days = AppDateUtils.weekDays(monday);
        for (var i = 1; i < days.length; i++) {
          expect(
            s.asignacionDe('gaseosa', days[i])!.participanteId,
            isNot(s.asignacionDe('gaseosa', days[i - 1])!.participanteId),
          );
        }
      }
    });

    test(
      'regla 2 cruza el fin de semana: el del viernes no repite el lunes',
      () {
        final base = ShiftsStateEntity.seed().copyWith(
          asignaciones: {
            'gaseosa': {
              prevFriday: const AssignmentEntity(participanteId: 'pedro'),
            },
          },
        );
        for (var seed = 0; seed < 20; seed++) {
          final engine = makeEngine(seed);
          final s = generateWholeWeek(engine, base, monday);
          expect(s.asignacionDe('gaseosa', monday)!.participanteId, isNot('pedro'));
        }
      },
    );

    test('regla 1: con menos de 4 presentes el día queda sin asignar', () {
      final engine = makeEngine();
      var s = engine.ensureWeekDefaults(ShiftsStateEntity.seed(), monday);
      s = engine.setPresencia(s, monday, ['wilson', 'pedro', 'natalia']);
      s = generateWholeWeek(engine, s, monday);

      expect(s.asignacionDe('gaseosa', monday)!.participanteId, isNull);
      expect(
        s.asignacionDe('gaseosa', monday)!.warning,
        ShiftsEngine.warnMinPresentes(4),
      );
      // Los demás días sí quedan asignados.
      expect(weekBuyers(s, monday), hasLength(4));
    });

    test('regla 5: fairness — quien más ha comprado no vuelve a salir', () {
      // Wilson acumula 5 gaseosas históricas; el resto está en 0.
      final history = <String, AssignmentEntity>{
        for (final day in AppDateUtils.weekDays(prevMonday))
          day: const AssignmentEntity(participanteId: 'wilson'),
      };
      final base = ShiftsStateEntity.seed().copyWith(
        asignaciones: {'gaseosa': history},
      );
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = generateWholeWeek(engine, base, monday);
        expect(weekBuyers(s, monday), isNot(contains('wilson')));
      }
    });

    test('regla 6: no repite la persona de vasos de la semana anterior', () {
      final base = ShiftsStateEntity.seed().copyWith(
        asignaciones: {
          'vasos': {
            prevMonday: const AssignmentEntity(participanteId: 'natalia'),
          },
        },
      );
      for (var seed = 0; seed < 20; seed++) {
        final engine = makeEngine(seed);
        final s = generateWholeWeek(engine, base, monday);
        expect(s.asignacionDe('vasos', monday)!.participanteId, isNot('natalia'));
      }
    });

    test('regla 6 se relaja con advertencia si no hay alternativa', () {
      final engine = makeEngine();
      final base = ShiftsStateEntity.seed().copyWith(
        participants: const [ParticipantEntity(id: 'wilson', name: 'Wilson')],
        asignaciones: {
          'vasos': {
            prevMonday: const AssignmentEntity(participanteId: 'wilson'),
          },
        },
      );
      final s = engine.autoAssignProducto(base, 'vasos', monday);
      expect(s.asignacionDe('vasos', monday)!.participanteId, 'wilson');
      expect(
        s.asignacionDe('vasos', monday)!.warning,
        ShiftsEngine.warnRepitePeriodoAnterior,
      );
    });

    test('regla 7: un día bloqueado no se sobreescribe al generar', () {
      final engine = makeEngine();
      var s = engine.ensureWeekDefaults(ShiftsStateEntity.seed(), monday);
      s = engine.manualSetProducto(s, 'gaseosa', monday, 'pedro');
      s = engine.toggleLock(s, 'gaseosa', monday);
      s = generateWholeWeek(engine, s, monday);

      expect(s.asignacionDe('gaseosa', monday)!.participanteId, 'pedro');
      expect(s.asignacionDe('gaseosa', monday)!.locked, isTrue);
      // Y el vasos elegido no puede ser pedro (regla 4 contra día bloqueado).
      expect(s.asignacionDe('vasos', monday)!.participanteId, isNot('pedro'));
    });

    test('regla 7: la semana de vasos bloqueada no se sobreescribe', () {
      final engine = makeEngine();
      var s = engine.manualSetProducto(
        ShiftsStateEntity.seed(),
        'vasos',
        monday,
        'natalia',
      );
      s = engine.toggleLock(s, 'vasos', monday);
      s = generateWholeWeek(engine, s, monday);

      expect(s.asignacionDe('vasos', monday)!.participanteId, 'natalia');
      expect(weekBuyers(s, monday), isNot(contains('natalia')));
    });
  });

  group('edición manual (regla 8)', () {
    test('asignar al de los vasos advierte pero no bloquea', () {
      final engine = makeEngine();
      var s = generateWholeWeek(engine, ShiftsStateEntity.seed(), monday);
      final vasosId = s.asignacionDe('vasos', monday)!.participanteId!;
      s = engine.manualSetProducto(s, 'gaseosa', monday, vasosId);

      expect(s.asignacionDe('gaseosa', monday)!.participanteId, vasosId);
      expect(s.asignacionDe('gaseosa', monday)!.warning, contains('vasos'));
    });

    test('repetir al comprador del día anterior advierte', () {
      final engine = makeEngine();
      var s = generateWholeWeek(engine, ShiftsStateEntity.seed(), monday);
      final mondayBuyer = s.asignacionDe('gaseosa', monday)!.participanteId!;
      s = engine.manualSetProducto(s, 'gaseosa', '2026-07-14', mondayBuyer);

      expect(s.asignacionDe('gaseosa', '2026-07-14')!.warning, contains('anterior'));
    });

    test('fijar vasos manual libera y reasigna los días de esa persona', () {
      final engine = makeEngine();
      var s = generateWholeWeek(engine, ShiftsStateEntity.seed(), monday);
      final mondayBuyer = s.asignacionDe('gaseosa', monday)!.participanteId!;
      s = engine.manualSetProducto(s, 'vasos', monday, mondayBuyer);

      expect(s.asignacionDe('vasos', monday)!.participanteId, mondayBuyer);
      expect(s.asignacionDe('gaseosa', monday)!.participanteId, isNot(mondayBuyer));
      expect(s.asignacionDe('gaseosa', monday)!.participanteId, isNotNull);
    });

    test('fijar vasos manual sobre un día bloqueado solo advierte', () {
      final engine = makeEngine();
      var s = engine.ensureWeekDefaults(ShiftsStateEntity.seed(), monday);
      s = engine.manualSetProducto(s, 'gaseosa', monday, 'pedro');
      s = engine.toggleLock(s, 'gaseosa', monday);
      s = engine.manualSetProducto(s, 'vasos', monday, 'pedro');

      expect(s.asignacionDe('gaseosa', monday)!.participanteId, 'pedro');
      expect(
        s.asignacionDe('gaseosa', monday)!.warning,
        ShiftsEngine.warnConflictoExclusionBloqueado('vasos'),
      );
    });

    test('quitar de presentes al asignado deja advertencia', () {
      final engine = makeEngine();
      var s = generateWholeWeek(engine, ShiftsStateEntity.seed(), monday);
      final buyer = s.asignacionDe('gaseosa', monday)!.participanteId!;
      final present = s
          .presentesEn(monday)
          .where((id) => id != buyer)
          .toList();
      s = engine.setPresencia(s, monday, present);

      expect(s.asignacionDe('gaseosa', monday)!.warning, contains('presente'));
    });
  });

  group('participantes', () {
    test('agregar nombre duplicado genera id único', () {
      const usecase = AddParticipantUseCase();
      final s = usecase(ShiftsStateEntity.seed(), 'Pedro');
      expect(s.participants.map((p) => p.id), contains('pedro-2'));
    });

    test('la presencia por defecto solo incluye activos', () {
      final engine = makeEngine();
      final base = ShiftsStateEntity.seed().copyWith(
        participants: [
          for (final p in ShiftsStateEntity.seed().participants)
            if (p.id == 'walter') p.copyWith(active: false) else p,
        ],
      );
      final s = engine.ensureWeekDefaults(base, monday);
      expect(s.presentesEn(monday), isNot(contains('walter')));
      expect(s.presentesEn(monday), hasLength(7));
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
