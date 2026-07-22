/// Calculadora de festivos de Colombia, sin dependencias externas ni tabla
/// estática que mantener a mano.
///
/// Combina tres categorías:
/// - Festivos **fijos**: nunca se mueven, aunque caigan en fin de semana.
/// - Festivos **Ley Emiliani**: si no caen en lunes, se trasladan al lunes
///   siguiente (Ley 51 de 1983).
/// - Festivos **móviles** dependientes de la Pascua (calculada con el
///   algoritmo de Gauss/computus): Jueves y Viernes Santo no se trasladan;
///   Ascensión, Corpus Christi y Sagrado Corazón sí aplican Ley Emiliani.
class ColombianHolidays {
  ColombianHolidays._();

  /// (mes, día) que nunca se mueven, así caigan en fin de semana.
  static const List<(int, int)> _fijos = [
    (1, 1), // Año Nuevo
    (5, 1), // Día del Trabajo
    (7, 20), // Independencia
    (8, 7), // Batalla de Boyacá
    (12, 8), // Inmaculada Concepción
    (12, 25), // Navidad
  ];

  /// (mes, día) civiles que se trasladan al lunes siguiente si no caen ya
  /// en lunes (Ley Emiliani).
  static const List<(int, int)> _emiliani = [
    (1, 6), // Reyes Magos
    (3, 19), // San José
    (6, 29), // San Pedro y San Pablo
    (8, 15), // Asunción de la Virgen
    (10, 12), // Día de la Raza
    (11, 1), // Todos los Santos
    (11, 11), // Independencia de Cartagena
  ];

  static final Map<int, Set<DateTime>> _cache = {};

  /// Domingo de Pascua para [year] (algoritmo de Gauss, calendario
  /// gregoriano).
  static DateTime _easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  /// [date] si ya es lunes; si no, el lunes siguiente.
  static DateTime _nextMondayOnOrAfter(DateTime date) {
    final delta = (DateTime.monday - date.weekday) % 7;
    return date.add(Duration(days: delta));
  }

  /// Todos los festivos colombianos de [year] (medianoche local, sin hora).
  static Set<DateTime> festivosDe(int year) {
    return _cache.putIfAbsent(year, () {
      final result = <DateTime>{};
      for (final (month, day) in _fijos) {
        result.add(DateTime(year, month, day));
      }
      for (final (month, day) in _emiliani) {
        result.add(_nextMondayOnOrAfter(DateTime(year, month, day)));
      }
      final easter = _easterSunday(year);
      result.add(easter.subtract(const Duration(days: 3))); // Jueves Santo
      result.add(easter.subtract(const Duration(days: 2))); // Viernes Santo
      result.add(
        _nextMondayOnOrAfter(easter.add(const Duration(days: 39))),
      ); // Ascensión del Señor
      result.add(
        _nextMondayOnOrAfter(easter.add(const Duration(days: 60))),
      ); // Corpus Christi
      result.add(
        _nextMondayOnOrAfter(easter.add(const Duration(days: 68))),
      ); // Sagrado Corazón de Jesús
      return result;
    });
  }

  /// `true` si [date] es festivo en Colombia (compara solo año/mes/día).
  static bool esFestivo(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return festivosDe(d.year).contains(d);
  }
}
