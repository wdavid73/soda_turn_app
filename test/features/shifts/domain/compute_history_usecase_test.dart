import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/features/shifts/domain/entities/assignment_entity.dart';
import 'package:turn_soda/features/shifts/domain/entities/generated_week_entity.dart';
import 'package:turn_soda/features/shifts/domain/entities/participant_entity.dart';
import 'package:turn_soda/features/shifts/domain/entities/shifts_state_entity.dart';
import 'package:turn_soda/features/shifts/domain/usecases/compute_history_usecase.dart';

void main() {
  const usecase = ComputeHistoryUseCase();
  const today = '2026-07-23'; // jueves

  ShiftsStateEntity buildState({
    Map<String, GeneratedWeekEntity> semanas = const {},
    Map<String, Map<String, AssignmentEntity>> asignaciones = const {},
  }) {
    return ShiftsStateEntity(
      participants: const [
        ParticipantEntity(id: 'wilson', name: 'Wilson'),
        ParticipantEntity(id: 'pedro', name: 'Pedro'),
      ],
      productos: ShiftsStateEntity.seedProductos,
      condiciones: ShiftsStateEntity.seedCondiciones,
      semanas: semanas,
      asignaciones: asignaciones,
    );
  }

  GeneratedWeekEntity week(String monday, String friday, EstadoSemana estado) =>
      GeneratedWeekEntity(monday: monday, friday: friday, estado: estado);

  group('ComputeHistoryUseCase', () {
    test('incluye semanas pasadas aunque el estado guardado diga enCurso '
        '(caso modo local, donde closeCompletedWeeks es no-op)', () {
      final state = buildState(
        semanas: {
          // Semana pasada con estado desactualizado.
          '2026-07-06': week('2026-07-06', '2026-07-10', EstadoSemana.enCurso),
        },
        asignaciones: {
          'gaseosa': {
            '2026-07-06': const AssignmentEntity(participanteId: 'wilson'),
          },
        },
      );

      final groups = usecase(state, today);
      expect(groups, hasLength(1));
      expect(groups.first.weeks.single.monday, '2026-07-06');
    });

    test('excluye la semana en curso y las planificadas', () {
      final state = buildState(
        semanas: {
          '2026-07-20': week('2026-07-20', '2026-07-24', EstadoSemana.enCurso),
          '2026-07-27': week(
            '2026-07-27',
            '2026-07-31',
            EstadoSemana.planificada,
          ),
        },
        asignaciones: {
          'gaseosa': {
            '2026-07-20': const AssignmentEntity(participanteId: 'wilson'),
          },
        },
      );

      expect(usecase(state, today), isEmpty);
    });

    test('omite semanas completadas sin ninguna asignación', () {
      final state = buildState(
        semanas: {
          '2026-07-06': week(
            '2026-07-06',
            '2026-07-10',
            EstadoSemana.completada,
          ),
        },
      );

      expect(usecase(state, today), isEmpty);
    });

    test('agrupa por mes descendente con conteos y gasto', () {
      final state = buildState(
        semanas: {
          '2026-06-22': week(
            '2026-06-22',
            '2026-06-26',
            EstadoSemana.completada,
          ),
          '2026-07-06': week(
            '2026-07-06',
            '2026-07-10',
            EstadoSemana.completada,
          ),
          '2026-07-13': week(
            '2026-07-13',
            '2026-07-17',
            EstadoSemana.completada,
          ),
        },
        asignaciones: {
          'gaseosa': {
            '2026-06-22': const AssignmentEntity(participanteId: 'wilson'),
            '2026-06-23': const AssignmentEntity(participanteId: 'pedro'),
            '2026-07-06': const AssignmentEntity(participanteId: 'wilson'),
            '2026-07-13': const AssignmentEntity(participanteId: 'pedro'),
            '2026-07-14': const AssignmentEntity(participanteId: 'wilson'),
          },
          'vasos': {
            '2026-07-06': const AssignmentEntity(participanteId: 'pedro'),
          },
        },
      );

      final groups = usecase(state, today);
      expect(groups.map((g) => g.monthKey), ['2026-07', '2026-06']);

      final julio = groups.first;
      expect(julio.label, 'Julio 2026');
      // Semanas del mes en orden descendente.
      expect(julio.weeks.map((w) => w.monday), ['2026-07-13', '2026-07-06']);
      expect(julio.conteoDe('gaseosa'), 3);
      expect(julio.conteoDe('vasos'), 1);
      // Solo la gaseosa tiene costo (7000 COP por día asignado).
      expect(julio.gastoCop, 3 * 7000);

      final junio = groups.last;
      expect(junio.conteoDe('gaseosa'), 2);
      expect(junio.conteoDe('vasos'), 0);
      expect(junio.gastoCop, 2 * 7000);
    });

    test('expone los días generables y el asignado semanal de cada semana',
        () {
      final state = buildState(
        semanas: {
          '2026-07-06': week(
            '2026-07-06',
            '2026-07-10',
            EstadoSemana.completada,
          ),
        },
        asignaciones: {
          'gaseosa': {
            '2026-07-06': const AssignmentEntity(participanteId: 'wilson'),
          },
          'vasos': {
            '2026-07-06': const AssignmentEntity(participanteId: 'pedro'),
          },
        },
      );

      final item = usecase(state, today).single.weeks.single;
      expect(item.weekNumber, 28);
      expect(item.dias, hasLength(5));
      expect(item.dias.first.participanteId, 'wilson');
      // Días sin asignación quedan como entradas nulas, no se ocultan.
      expect(item.dias[1].participanteId, isNull);
      expect(item.semanales['vasos'], 'pedro');
    });
  });
}
