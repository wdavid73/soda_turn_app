/// Utilidades de fecha para semanas hábiles (lunes a viernes).
///
/// Todas las fechas viajan como String ISO `yyyy-MM-dd`, igual que las claves
/// del esquema web v2, para que el estado persistido sea compatible.
class AppDateUtils {
  AppDateUtils._();

  static const List<String> dayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  static const List<String> dayNamesShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie'];

  static const List<String> _monthsShort = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static String toIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  static DateTime parseIso(String iso) => DateTime.parse(iso);

  /// Lunes de la semana a la que pertenece [d].
  static DateTime mondayOf(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    return date.subtract(Duration(days: date.weekday - DateTime.monday));
  }

  /// Lunes "activo" para [d]: en fin de semana salta al lunes siguiente,
  /// porque la planeación del sábado/domingo ya es para la semana entrante.
  static String activeMondayIso(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    if (date.weekday >= DateTime.saturday) {
      return toIso(date.add(Duration(days: 8 - date.weekday)));
    }
    return toIso(mondayOf(date));
  }

  /// Los 5 días hábiles (ISO) de la semana que empieza en [mondayIso].
  static List<String> weekDays(String mondayIso) {
    final monday = parseIso(mondayIso);
    return List.generate(5, (i) => toIso(monday.add(Duration(days: i))));
  }

  /// Día hábil anterior: lunes → viernes pasado (la regla 2 cruza el finde).
  static String previousBusinessDay(String iso) {
    final d = parseIso(iso);
    final delta = d.weekday == DateTime.monday ? 3 : 1;
    return toIso(d.subtract(Duration(days: delta)));
  }

  /// Día hábil siguiente: viernes → lunes próximo.
  static String nextBusinessDay(String iso) {
    final d = parseIso(iso);
    final delta = d.weekday == DateTime.friday ? 3 : 1;
    return toIso(d.add(Duration(days: delta)));
  }

  static String previousMonday(String mondayIso) =>
      toIso(parseIso(mondayIso).subtract(const Duration(days: 7)));

  static String nextMonday(String mondayIso) =>
      toIso(parseIso(mondayIso).add(const Duration(days: 7)));

  /// Índice 0..4 (lunes..viernes) o -1 si es fin de semana.
  static int weekdayIndex(String iso) {
    final w = parseIso(iso).weekday;
    return w >= DateTime.saturday ? -1 : w - DateTime.monday;
  }

  /// Etiqueta corta de un día, ej. "Lunes 13".
  static String dayLabel(String iso) {
    final d = parseIso(iso);
    final idx = weekdayIndex(iso);
    final name = idx >= 0 ? dayNames[idx] : '';
    return '$name ${d.day}'.trim();
  }

  /// Rango legible de la semana, ej. "13 – 17 jul 2026".
  static String weekRangeLabel(String mondayIso) {
    final monday = parseIso(mondayIso);
    final friday = monday.add(const Duration(days: 4));
    final sameMonth = monday.month == friday.month;
    final start = sameMonth
        ? '${monday.day}'
        : '${monday.day} ${_monthsShort[monday.month - 1]}';
    final end =
        '${friday.day} ${_monthsShort[friday.month - 1]} ${friday.year}';
    return '$start – $end';
  }

  /// `true` si [iso] es la fecha de hoy.
  static bool isToday(String iso) => iso == toIso(DateTime.now());
}
