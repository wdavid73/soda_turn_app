import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../entities/day_assignment_entity.dart';
import '../entities/turnos_state_entity.dart';
import '../entities/weekly_vasos_entity.dart';
import 'fair_picker_service.dart';

/// Motor de reglas v2. Todas las operaciones son puras: reciben un estado y
/// devuelven uno nuevo; la persistencia ocurre fuera (ViewModel → repositorio).
///
/// Dureza de las reglas:
/// - Regla 4 (vasos no compra gaseosa esa semana): DURA en flujo automático,
///   solo advertencia cuando el usuario fuerza algo manualmente o con 🔒.
/// - Reglas 2 (no repetir día hábil siguiente) y 6 (no repetir vasos de la
///   semana anterior): BLANDAS, se relajan con advertencia si no hay opción.
class TurnosEngine {
  final FairPickerService picker;

  const TurnosEngine(this.picker);

  static const String warnMinPresentes =
      'Menos de ${AppConstants.minPresentes} presentes: día sin asignar.';
  static const String warnSinCandidatos =
      'Sin candidatos: quien lleva los vasos es el único presente.';
  static const String warnRepiteDiaSeguido =
      'Se relajó la regla de no repetir dos días hábiles seguidos.';
  static const String warnConflictoVasosDiaBloqueado =
      'Conflicto: también lleva los vasos esta semana (día bloqueado).';
  static const String warnRepiteVasosSemana =
      'Repite los vasos de la semana pasada: no había alternativa.';
  static const String warnVasosConDiaBloqueado =
      'Conflicto: ya tiene gaseosa en un día bloqueado de esta semana.';
  static const String warnSemanaSinPresentes =
      'No hay nadie presente esta semana.';

  /// Crea los registros de la semana que falten: presencia por defecto =
  /// participantes activos, y el registro semanal de vasos vacío.
  TurnosStateEntity ensureWeekDefaults(
    TurnosStateEntity state,
    String mondayIso,
  ) {
    final assignments = Map.of(state.assignments);
    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      assignments.putIfAbsent(
        dayIso,
        () => DayAssignmentEntity(present: state.activeIds),
      );
    }
    final weekly = Map.of(state.weeklyVasos);
    weekly.putIfAbsent(mondayIso, () => const WeeklyVasosEntity());
    return state.copyWith(assignments: assignments, weeklyVasos: weekly);
  }

  /// Unión de presentes de los 5 días: elegibles para los vasos (regla 3).
  List<String> weekPresenceUnion(TurnosStateEntity state, String mondayIso) {
    final present = <String>{};
    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      present.addAll(state.assignments[dayIso]?.present ?? const []);
    }
    return [
      for (final p in state.participants)
        if (present.contains(p.id)) p.id,
    ];
  }

  /// Decide el comprador de vasos de la semana (reglas 3, 4, 5 y 6).
  /// Respeta el bloqueo 🔒 de la semana.
  TurnosStateEntity pickWeeklyVasos(TurnosStateEntity state, String mondayIso) {
    var s = ensureWeekDefaults(state, mondayIso);
    final rec = s.weeklyVasos[mondayIso]!;
    if (rec.locked) return s;

    final pool = weekPresenceUnion(s, mondayIso);
    if (pool.isEmpty) {
      return _setWeek(
        s,
        mondayIso,
        rec.copyWith(personId: null, warning: warnSemanaSinPresentes),
      );
    }

    String? warning;

    // Regla 4 frente a días bloqueados: no elegir de vasos a quien ya tiene
    // gaseosa fijada en un día bloqueado de esta semana.
    final lockedBuyers = <String>{
      for (final dayIso in AppDateUtils.weekDays(mondayIso))
        if ((s.assignments[dayIso]?.locked ?? false) &&
            s.assignments[dayIso]?.gaseosa != null)
          s.assignments[dayIso]!.gaseosa!,
    };
    var candidates = pool.where((id) => !lockedBuyers.contains(id)).toList();
    if (candidates.isEmpty) {
      candidates = pool;
      warning = warnVasosConDiaBloqueado;
    }

    // Regla 6 (blanda): evitar repetir a la persona de la semana anterior.
    final prevWeekId =
        s.weeklyVasos[AppDateUtils.previousMonday(mondayIso)]?.personId;
    var soft = candidates.where((id) => id != prevWeekId).toList();
    if (soft.isEmpty) {
      soft = candidates;
      warning ??= warnRepiteVasosSemana;
    }

    // Fairness sin contar el pick vigente de esta misma semana.
    final statsBase = _setWeek(s, mondayIso, rec.copyWith(personId: null));
    final stats = picker.computeStats(statsBase);
    final pickId = picker.pickFair(soft, stats.vasosCount);
    return _setWeek(
      s,
      mondayIso,
      rec.copyWith(personId: pickId, warning: warning),
    );
  }

  /// Asigna la gaseosa de un día (reglas 1, 2, 4 y 5). Respeta el 🔒 del día.
  TurnosStateEntity autoAssignGaseosaDay(
    TurnosStateEntity state,
    String dateIso,
  ) {
    final day = state.assignments[dateIso];
    if (day == null || day.locked) return state;

    if (day.present.length < AppConstants.minPresentes) {
      return _setDay(
        state,
        dateIso,
        day.copyWith(gaseosa: null, warning: warnMinPresentes),
      );
    }

    final mondayIso = _mondayOfDay(dateIso);
    final vasosId = state.weeklyVasos[mondayIso]?.personId;

    // Regla 4 (dura): quien lleva los vasos queda excluido siempre.
    final pool = day.present.where((id) => id != vasosId).toList();
    if (pool.isEmpty) {
      return _setDay(
        state,
        dateIso,
        day.copyWith(gaseosa: null, warning: warnSinCandidatos),
      );
    }

    // Regla 2 (blanda): evitar al comprador del día hábil anterior/siguiente.
    String? warning;
    final prevBuyer =
        state.assignments[AppDateUtils.previousBusinessDay(dateIso)]?.gaseosa;
    final nextBuyer =
        state.assignments[AppDateUtils.nextBusinessDay(dateIso)]?.gaseosa;
    var soft = pool.where((id) => id != prevBuyer && id != nextBuyer).toList();
    if (soft.isEmpty) {
      soft = pool;
      warning = warnRepiteDiaSeguido;
    }

    // Fairness sin contar el pick vigente del propio día.
    final statsBase = _setDay(state, dateIso, day.copyWith(gaseosa: null));
    final stats = picker.computeStats(statsBase);
    final pickId = picker.pickFair(soft, stats.gaseosaCount);
    return _setDay(
      state,
      dateIso,
      day.copyWith(gaseosa: pickId, warning: warning),
    );
  }

  /// Orquesta la semana completa: defaults → limpia días sin 🔒 →
  /// vasos de la semana → gaseosa día por día excluyendo a esa persona.
  TurnosStateEntity generateWeek(TurnosStateEntity state, String mondayIso) {
    var s = ensureWeekDefaults(state, mondayIso);

    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      final day = s.assignments[dayIso]!;
      if (!day.locked) {
        s = _setDay(s, dayIso, day.copyWith(gaseosa: null, warning: null));
      }
    }

    s = pickWeeklyVasos(s, mondayIso);
    final vasosId = s.weeklyVasos[mondayIso]?.personId;

    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      final day = s.assignments[dayIso]!;
      if (day.locked) {
        if (day.gaseosa != null && day.gaseosa == vasosId) {
          s = _setDay(
            s,
            dayIso,
            day.copyWith(warning: warnConflictoVasosDiaBloqueado),
          );
        }
        continue;
      }
      s = autoAssignGaseosaDay(s, dayIso);
    }
    return s;
  }

  /// Re-elige los vasos de la semana y libera/reasigna los días de gaseosa
  /// que queden en conflicto con la persona elegida.
  TurnosStateEntity autoAssignWeeklyVasos(
    TurnosStateEntity state,
    String mondayIso,
  ) {
    final s = pickWeeklyVasos(state, mondayIso);
    return _resolveVasosGaseosaConflicts(s, mondayIso);
  }

  /// Sobrescritura manual de la gaseosa de un día: siempre se permite,
  /// pero se calcula la advertencia de toda regla que se rompa (regla 8).
  TurnosStateEntity manualSetGaseosa(
    TurnosStateEntity state,
    String dateIso,
    String? personId,
  ) {
    final day =
        state.assignments[dateIso] ??
        DayAssignmentEntity(present: state.activeIds);
    final warning = personId == null
        ? null
        : _manualGaseosaWarning(state, dateIso, day, personId);
    return _setDay(
      state,
      dateIso,
      day.copyWith(gaseosa: personId, warning: warning),
    );
  }

  String? _manualGaseosaWarning(
    TurnosStateEntity state,
    String dateIso,
    DayAssignmentEntity day,
    String personId,
  ) {
    final issues = <String>[];
    final vasosId = state.weeklyVasos[_mondayOfDay(dateIso)]?.personId;
    if (vasosId == personId) {
      issues.add('También lleva los vasos esta semana.');
    }
    if (state.assignments[AppDateUtils.previousBusinessDay(dateIso)]?.gaseosa ==
        personId) {
      issues.add('Compró gaseosa el día hábil anterior.');
    }
    if (state.assignments[AppDateUtils.nextBusinessDay(dateIso)]?.gaseosa ==
        personId) {
      issues.add('Compra gaseosa el día hábil siguiente.');
    }
    if (!day.present.contains(personId)) {
      issues.add('No está marcado como presente ese día.');
    }
    if (day.present.length < AppConstants.minPresentes) {
      issues.add('Hay menos de ${AppConstants.minPresentes} presentes.');
    }
    return issues.isEmpty ? null : issues.join(' ');
  }

  /// Sobrescritura manual de los vasos de la semana: libera los días de
  /// gaseosa de esa persona (sin 🔒) y los reintenta automáticamente.
  TurnosStateEntity manualSetWeeklyVasos(
    TurnosStateEntity state,
    String mondayIso,
    String? personId,
  ) {
    var s = ensureWeekDefaults(state, mondayIso);
    final rec = s.weeklyVasos[mondayIso]!;
    String? warning;
    if (personId != null &&
        s.weeklyVasos[AppDateUtils.previousMonday(mondayIso)]?.personId ==
            personId) {
      warning = 'También llevó los vasos la semana pasada.';
    }
    s = _setWeek(
      s,
      mondayIso,
      rec.copyWith(personId: personId, warning: warning),
    );
    if (personId == null) return s;
    return _resolveVasosGaseosaConflicts(s, mondayIso);
  }

  /// Edita los presentes de un día y recalcula la advertencia del asignado.
  TurnosStateEntity setPresence(
    TurnosStateEntity state,
    String dateIso,
    List<String> present,
  ) {
    final day = state.assignments[dateIso] ?? const DayAssignmentEntity();
    var updated = day.copyWith(present: present);
    if (updated.gaseosa != null) {
      final issues = <String>[];
      if (!present.contains(updated.gaseosa)) {
        issues.add('El asignado ya no está presente.');
      }
      if (present.length < AppConstants.minPresentes) {
        issues.add('Hay menos de ${AppConstants.minPresentes} presentes.');
      }
      updated = updated.copyWith(
        warning: issues.isEmpty ? null : issues.join(' '),
      );
    } else if (present.length < AppConstants.minPresentes) {
      updated = updated.copyWith(warning: warnMinPresentes);
    } else {
      updated = updated.copyWith(warning: null);
    }
    return _setDay(state, dateIso, updated);
  }

  TurnosStateEntity toggleDayLock(TurnosStateEntity state, String dateIso) {
    final day = state.assignments[dateIso];
    if (day == null) return state;
    return _setDay(state, dateIso, day.copyWith(locked: !day.locked));
  }

  TurnosStateEntity toggleWeekVasosLock(
    TurnosStateEntity state,
    String mondayIso,
  ) {
    final s = ensureWeekDefaults(state, mondayIso);
    final rec = s.weeklyVasos[mondayIso]!;
    return _setWeek(s, mondayIso, rec.copyWith(locked: !rec.locked));
  }

  /// Libera (y reintenta) los días de gaseosa asignados a quien quedó de
  /// vasos; en días con 🔒 solo deja la advertencia (el usuario manda).
  TurnosStateEntity _resolveVasosGaseosaConflicts(
    TurnosStateEntity state,
    String mondayIso,
  ) {
    var s = state;
    final vasosId = s.weeklyVasos[mondayIso]?.personId;
    if (vasosId == null) return s;
    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      final day = s.assignments[dayIso];
      if (day == null || day.gaseosa != vasosId) continue;
      if (day.locked) {
        s = _setDay(
          s,
          dayIso,
          day.copyWith(warning: warnConflictoVasosDiaBloqueado),
        );
      } else {
        s = _setDay(s, dayIso, day.copyWith(gaseosa: null, warning: null));
        s = autoAssignGaseosaDay(s, dayIso);
      }
    }
    return s;
  }

  String _mondayOfDay(String dateIso) =>
      AppDateUtils.toIso(AppDateUtils.mondayOf(AppDateUtils.parseIso(dateIso)));

  TurnosStateEntity _setDay(
    TurnosStateEntity state,
    String dateIso,
    DayAssignmentEntity day,
  ) {
    return state.copyWith(assignments: {...state.assignments, dateIso: day});
  }

  TurnosStateEntity _setWeek(
    TurnosStateEntity state,
    String mondayIso,
    WeeklyVasosEntity rec,
  ) {
    return state.copyWith(weeklyVasos: {...state.weeklyVasos, mondayIso: rec});
  }
}
