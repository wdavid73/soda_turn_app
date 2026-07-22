import 'package:flutter_test/flutter_test.dart';
import 'package:turn_soda/core/utils/colombian_holidays.dart';

bool _esFestivo(int y, int m, int d) =>
    ColombianHolidays.esFestivo(DateTime(y, m, d));

void main() {
  group('ColombianHolidays', () {
    test('festivos fijos no se mueven aunque caigan en fin de semana', () {
      // Jul 20 2024 cae sábado; Dec 8 2024 cae domingo.
      expect(_esFestivo(2024, 7, 20), isTrue);
      expect(_esFestivo(2024, 12, 8), isTrue);
    });

    test('calendario oficial de Colombia 2024 completo (18 festivos)', () {
      final esperados = <(int, int)>[
        (1, 1), (1, 8), // Año Nuevo, Reyes (trasladado)
        (3, 25), (3, 28), (3, 29), // San José (trasladado), Jueves, Viernes Santo
        (5, 1), (5, 13), // Trabajo, Ascensión (trasladada)
        (6, 3), (6, 10), // Corpus Christi, Sagrado Corazón (trasladados)
        (7, 1), (7, 20), // San Pedro y San Pablo (trasladado), Independencia
        (8, 7), (8, 19), // Boyacá, Asunción (trasladada)
        (10, 14), // Día de la Raza (trasladado)
        (11, 4), (11, 11), // Todos los Santos (trasladado), Cartagena
        (12, 8), (12, 25), // Inmaculada, Navidad
      ];
      final actuales = ColombianHolidays.festivosDe(2024);
      expect(actuales.length, esperados.length);
      for (final (m, d) in esperados) {
        expect(
          actuales.contains(DateTime(2024, m, d)),
          isTrue,
          reason: '2024-$m-$d debería ser festivo',
        );
      }
    });

    test(
      '2025: San Pedro y San Pablo coincide con Sagrado Corazón (jun 30)',
      () {
        expect(_esFestivo(2025, 6, 30), isTrue);
        // La coincidencia reduce el total de fechas únicas a 17 ese año.
        expect(ColombianHolidays.festivosDe(2025).length, 17);
      },
    );

    test('festivos Ley Emiliani caen siempre en lunes', () {
      for (final year in [2024, 2025, 2026]) {
        for (final fecha in ColombianHolidays.festivosDe(year)) {
          final esFijo =
              (fecha.month == 1 && fecha.day == 1) ||
              (fecha.month == 5 && fecha.day == 1) ||
              (fecha.month == 7 && fecha.day == 20) ||
              (fecha.month == 8 && fecha.day == 7) ||
              (fecha.month == 12 && fecha.day == 8) ||
              (fecha.month == 12 && fecha.day == 25);
          final esViernesOJuevesSanto =
              fecha.weekday == DateTime.thursday ||
              fecha.weekday == DateTime.friday;
          if (!esFijo && !esViernesOJuevesSanto) {
            expect(
              fecha.weekday,
              DateTime.monday,
              reason: '$fecha debería ser lunes ($year)',
            );
          }
        }
      }
    });

    test('Jueves y Viernes Santo son 3 y 2 días antes de Pascua', () {
      // Pascua 2026 conocida: 5 de abril.
      expect(_esFestivo(2026, 4, 2), isTrue); // Jueves Santo
      expect(_esFestivo(2026, 4, 3), isTrue); // Viernes Santo
    });

    test('un día ordinario no es festivo', () {
      expect(_esFestivo(2026, 7, 21), isFalse);
    });
  });
}
