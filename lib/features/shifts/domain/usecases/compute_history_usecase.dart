import '../../../../core/utils/app_date_utils.dart';
import '../entities/generated_week_entity.dart';
import '../entities/shifts_state_entity.dart';
import '../services/week_state_service.dart';

/// Asignación de un producto diario en un día concreto de la semana.
class HistoryDayEntry {
  final String dayIso;
  final String productoId;

  /// Asignado del día (null = el día quedó sin asignación).
  final String? participanteId;

  const HistoryDayEntry({
    required this.dayIso,
    required this.productoId,
    this.participanteId,
  });
}

/// Semana completada lista para pintar en el historial.
class HistoryWeekItem {
  /// Lunes ISO (clave natural de la semana).
  final String monday;

  /// Número de semana ISO-8601, ej. 42.
  final int weekNumber;

  /// Días generables de la semana con su asignado del producto diario.
  final List<HistoryDayEntry> dias;

  /// Producto semanal → asignado de la semana (ej. `vasos` → id).
  final Map<String, String?> semanales;

  const HistoryWeekItem({
    required this.monday,
    required this.weekNumber,
    required this.dias,
    required this.semanales,
  });
}

/// Grupo de semanas completadas de un mismo mes.
class HistoryMonthGroup {
  /// Clave de agrupación, ej. "2025-10".
  final String monthKey;

  /// Etiqueta visible, ej. "Octubre 2025".
  final String label;

  /// Semanas del mes, de la más reciente a la más antigua.
  final List<HistoryWeekItem> weeks;

  /// Turnos asignados por producto en el mes (gaseosa: días, vasos: semanas).
  final Map<String, int> conteoPorProducto;

  /// Gasto del mes: asignaciones × costo del producto (solo productos con
  /// costo configurado; los vasos no suman dinero).
  final int gastoCop;

  const HistoryMonthGroup({
    required this.monthKey,
    required this.label,
    required this.weeks,
    required this.conteoPorProducto,
    required this.gastoCop,
  });

  int conteoDe(String productoId) => conteoPorProducto[productoId] ?? 0;
}

/// Deriva el historial (semanas completadas agrupadas por mes) del estado ya
/// cargado. No consulta nada: `load()` pliega las filas de `historico` dentro
/// de `asignaciones`, y en modo local el blob conserva todo. El estado
/// "completada" se deriva con [WeekStateService] porque el campo persistido
/// puede quedar desactualizado en modo local.
class ComputeHistoryUseCase {
  const ComputeHistoryUseCase();

  List<HistoryMonthGroup> call(ShiftsStateEntity state, String todayIso) {
    final diarios = <String>[
      for (final p in state.productos)
        if (state.condicionDe(p.id)?.esDiario ?? false) p.id,
    ];
    final semanales = <String>[
      for (final p in state.productos)
        if (state.condicionDe(p.id)?.esSemanalOMensual ?? false) p.id,
    ];

    final weeks = <HistoryWeekItem>[];
    for (final semana in state.semanas.values) {
      if (WeekStateService.estadoDe(semana, todayIso) !=
          EstadoSemana.completada) {
        continue;
      }
      final item = _buildWeek(state, semana, diarios, semanales);
      if (item != null) weeks.add(item);
    }
    weeks.sort((a, b) => b.monday.compareTo(a.monday));

    final groups = <String, List<HistoryWeekItem>>{};
    for (final week in weeks) {
      groups
          .putIfAbsent(AppDateUtils.monthKeyOf(week.monday), () => [])
          .add(week);
    }

    return [
      for (final entry in groups.entries)
        _buildGroup(state, entry.key, entry.value),
    ];
  }

  /// Arma la semana o devuelve null si no tiene ninguna asignación (semana
  /// configurada pero nunca generada: no aporta nada al historial).
  HistoryWeekItem? _buildWeek(
    ShiftsStateEntity state,
    GeneratedWeekEntity semana,
    List<String> diarios,
    List<String> semanales,
  ) {
    final dias = <HistoryDayEntry>[];
    var hayAsignacion = false;

    for (final dayIso in AppDateUtils.weekDays(semana.monday)) {
      if (!AppDateUtils.esDiaGenerable(dayIso)) continue;
      for (final productoId in diarios) {
        final id = state.asignacionDe(productoId, dayIso)?.participanteId;
        if (id != null) hayAsignacion = true;
        dias.add(
          HistoryDayEntry(
            dayIso: dayIso,
            productoId: productoId,
            participanteId: id,
          ),
        );
      }
    }

    final porSemana = <String, String?>{};
    for (final productoId in semanales) {
      final id = state.asignacionDe(productoId, semana.monday)?.participanteId;
      porSemana[productoId] = id;
      if (id != null) hayAsignacion = true;
    }

    if (!hayAsignacion) return null;
    return HistoryWeekItem(
      monday: semana.monday,
      weekNumber: AppDateUtils.isoWeekNumber(semana.monday),
      dias: dias,
      semanales: porSemana,
    );
  }

  HistoryMonthGroup _buildGroup(
    ShiftsStateEntity state,
    String monthKey,
    List<HistoryWeekItem> weeks,
  ) {
    final conteo = <String, int>{};
    for (final week in weeks) {
      for (final dia in week.dias) {
        if (dia.participanteId == null) continue;
        conteo[dia.productoId] = (conteo[dia.productoId] ?? 0) + 1;
      }
      for (final entry in week.semanales.entries) {
        if (entry.value == null) continue;
        conteo[entry.key] = (conteo[entry.key] ?? 0) + 1;
      }
    }

    var gasto = 0;
    for (final entry in conteo.entries) {
      final costo = state.condicionDe(entry.key)?.costoCop;
      if (costo != null) gasto += entry.value * costo;
    }

    return HistoryMonthGroup(
      monthKey: monthKey,
      label: AppDateUtils.monthYearLabel('$monthKey-01'),
      weeks: weeks,
      conteoPorProducto: conteo,
      gastoCop: gasto,
    );
  }
}
