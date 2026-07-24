import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/core/utils/app_date_utils.dart';

void main() {
  group('AppDateUtils', () {
    test('mondayOf devuelve el lunes de la semana', () {
      expect(
        AppDateUtils.toIso(AppDateUtils.mondayOf(DateTime(2026, 7, 16))),
        '2026-07-13',
      );
      expect(
        AppDateUtils.toIso(AppDateUtils.mondayOf(DateTime(2026, 7, 13))),
        '2026-07-13',
      );
    });

    test('activeMondayIso salta al lunes siguiente en fin de semana', () {
      expect(AppDateUtils.activeMondayIso(DateTime(2026, 7, 18)), '2026-07-20');
      expect(AppDateUtils.activeMondayIso(DateTime(2026, 7, 19)), '2026-07-20');
      expect(AppDateUtils.activeMondayIso(DateTime(2026, 7, 15)), '2026-07-13');
    });

    test('weekDays devuelve los 5 días hábiles', () {
      expect(AppDateUtils.weekDays('2026-07-13'), [
        '2026-07-13',
        '2026-07-14',
        '2026-07-15',
        '2026-07-16',
        '2026-07-17',
      ]);
    });

    test('previousBusinessDay cruza el fin de semana (lunes → viernes)', () {
      expect(AppDateUtils.previousBusinessDay('2026-07-13'), '2026-07-10');
      expect(AppDateUtils.previousBusinessDay('2026-07-14'), '2026-07-13');
    });

    test('nextBusinessDay cruza el fin de semana (viernes → lunes)', () {
      expect(AppDateUtils.nextBusinessDay('2026-07-17'), '2026-07-20');
      expect(AppDateUtils.nextBusinessDay('2026-07-14'), '2026-07-15');
    });

    test('weekRangeLabel formatea el rango de la semana', () {
      expect(AppDateUtils.weekRangeLabel('2026-07-13'), '13 – 17 jul 2026');
      expect(AppDateUtils.weekRangeLabel('2026-06-29'), '29 jun – 3 jul 2026');
    });

    test('esDiaGenerable es false en fines de semana y festivos', () {
      expect(AppDateUtils.esDiaGenerable('2026-07-13'), isTrue); // lunes
      expect(AppDateUtils.esDiaGenerable('2026-07-18'), isFalse); // sábado
      expect(AppDateUtils.esDiaGenerable('2026-05-01'), isFalse); // festivo (viernes)
    });

    test('previousGenerableDay/nextGenerableDay saltan festivos y finde', () {
      // 2026-05-01 (viernes) es festivo (Día del Trabajo).
      expect(AppDateUtils.previousGenerableDay('2026-05-04'), '2026-04-30');
      expect(AppDateUtils.nextGenerableDay('2026-04-30'), '2026-05-04');
    });

    test('monthYearLabel usa el mes del lunes', () {
      expect(AppDateUtils.monthYearLabel('2026-07-13'), 'Julio 2026');
      // Semana que cruza de mes: pertenece al mes del lunes.
      expect(AppDateUtils.monthYearLabel('2026-06-29'), 'Junio 2026');
    });

    test('monthKeyOf devuelve la clave yyyy-MM del lunes', () {
      expect(AppDateUtils.monthKeyOf('2026-07-13'), '2026-07');
      expect(AppDateUtils.monthKeyOf('2026-06-29'), '2026-06');
    });

    test('isoWeekNumber sigue la regla ISO-8601 (año del jueves)', () {
      // La semana del 29-dic-2025 contiene el jueves 1-ene-2026 → semana 1.
      expect(AppDateUtils.isoWeekNumber('2025-12-29'), 1);
      expect(AppDateUtils.isoWeekNumber('2026-01-05'), 2);
      expect(AppDateUtils.isoWeekNumber('2026-07-13'), 29);
      // 2024-12-30: el jueves es 2-ene-2025 → semana 1 de 2025.
      expect(AppDateUtils.isoWeekNumber('2024-12-30'), 1);
    });
  });
}
