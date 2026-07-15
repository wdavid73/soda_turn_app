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
  });
}
