import '../../../../core/utils/app_date_utils.dart';
import '../entities/generated_week_entity.dart';

/// Deriva el [EstadoSemana] de una semana a partir de la fecha de hoy, en
/// vez de confiar en un valor persistido que podría desincronizarse (ej. si
/// el viernes es festivo, la semana se cierra un día antes).
class WeekStateService {
  WeekStateService._();

  static EstadoSemana estadoDe(GeneratedWeekEntity semana, String todayIso) {
    if (todayIso.compareTo(semana.monday) < 0) return EstadoSemana.planificada;
    final ultimoGenerable = ultimoDiaGenerable(semana.monday, semana.friday);
    if (todayIso.compareTo(ultimoGenerable) > 0) return EstadoSemana.completada;
    return EstadoSemana.enCurso;
  }

  /// Último día generable (hábil y no festivo) de la semana, sin cruzar
  /// hacia atrás del lunes.
  static String ultimoDiaGenerable(String mondayIso, String fridayIso) {
    var d = fridayIso;
    while (!AppDateUtils.esDiaGenerable(d) && d.compareTo(mondayIso) > 0) {
      d = AppDateUtils.toIso(
        AppDateUtils.parseIso(d).subtract(const Duration(days: 1)),
      );
    }
    return d;
  }
}
