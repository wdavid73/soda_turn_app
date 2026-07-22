import '../../../../core/utils/app_date_utils.dart';
import '../entities/assignment_entity.dart';
import '../entities/product_condition_entity.dart';
import '../entities/product_exclusion_entity.dart';
import '../entities/generated_week_entity.dart';
import '../entities/shifts_state_entity.dart';
import 'fair_picker_service.dart';
import 'week_state_service.dart';

/// Motor de reglas genérico: opera sobre cualquier producto configurado en
/// `condicion_producto`, no solo gaseosa/vasos. Todas las operaciones son
/// puras: reciben un estado y devuelven uno nuevo; la persistencia ocurre
/// fuera (ViewModel → repositorio).
///
/// Pipeline de `autoAssignProducto` (generaliza las reglas 1, 2, 4, 5 y 6
/// del MVP v1, ver docs/02-reglas-negocio.md):
/// 1. Pool a partir de la presencia del periodo (unión semanal para
///    productos semanales).
/// 2. Exclusión por `producto_exclusiones` (regla 4 generalizada): dura
///    cuando el otro producto es semanal (siempre se descarta a quien ya
///    lo tenga esa semana); blanda-con-locked cuando el otro producto es
///    diario a escala de semana (solo descarta a quien lo tenga en un
///    periodo bloqueado, para no romper compromisos ya fijados).
/// 3. Mínimo de presentes (regla 1 generalizada), solo para productos
///    diarios.
/// 4. "No repetir periodo anterior" (reglas 2 y 6 unificadas): día
///    hábil/generable anterior y siguiente para productos diarios, semana
///    anterior para productos semanales.
/// 5. Equilibrio semanal (regla 5b, ver docs/02-reglas-negocio.md): entre
///    quienes sobrevivan los filtros anteriores, se prefiere a quien menos
///    veces haya tenido este producto en la semana en curso.
/// 6. Reparto justo histórico (regla 5): desempate final por menor conteo
///    en todo el historial guardado.
class ShiftsEngine {
  final FairPickerService picker;

  const ShiftsEngine(this.picker);

  static String warnMinPresentes(int min) =>
      'Menos de $min presentes: periodo sin asignar.';
  static const String warnSinCandidatos =
      'Sin candidatos: no hay nadie disponible para este periodo.';
  static const String warnRepitePeriodoAnterior =
      'Se relajó la regla de no repetir el periodo anterior.';
  static const String warnSemanaSinPresentes =
      'No hay nadie presente esta semana.';

  static String warnConflictoExclusionBloqueado(String otroProducto) =>
      'Conflicto: también tiene $otroProducto en un periodo bloqueado de esta semana.';
  static String warnConflictoExclusion(String otroProducto) =>
      'Conflicto: también tiene $otroProducto esta semana.';

  // ── Configuración de semana ─────────────────────────────────────────────

  /// Crea (si falta) el registro de semana con los participantes activos
  /// por defecto, y la presencia por defecto de cada día generable.
  ShiftsStateEntity ensureWeekDefaults(
    ShiftsStateEntity state,
    String mondayIso,
  ) {
    var semanas = state.semanas;
    if (!semanas.containsKey(mondayIso)) {
      final friday = AppDateUtils.weekDays(mondayIso).last;
      semanas = {
        ...semanas,
        mondayIso: GeneratedWeekEntity(
          monday: mondayIso,
          friday: friday,
          participantes: [
            for (final id in state.activeIds)
              SemanaParticipanteEntity(participanteId: id, agregadoEn: mondayIso),
          ],
        ),
      };
    }
    final semana = semanas[mondayIso]!;
    var presencia = state.presenciaPorDia;
    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      if (!presencia.containsKey(dayIso)) {
        presencia = {
          ...presencia,
          dayIso: semana.participantesElegiblesEn(dayIso),
        };
      }
    }
    return state.copyWith(semanas: semanas, presenciaPorDia: presencia);
  }

  /// Configura (o reconfigura) la semana con un conjunto explícito de
  /// participantes desde el día de hoy en adelante.
  ShiftsStateEntity configureWeek(
    ShiftsStateEntity state,
    String mondayIso,
    List<String> participantIds,
    String fechaConfiguracion,
  ) {
    var s = ensureWeekDefaults(state, mondayIso);
    final participantes = [
      for (final id in participantIds)
        SemanaParticipanteEntity(participanteId: id, agregadoEn: fechaConfiguracion),
    ];
    return _setSemana(
      s,
      mondayIso,
      s.semanaDe(mondayIso)!.copyWith(participantes: participantes),
    );
  }

  ShiftsStateEntity addWeekParticipant(
    ShiftsStateEntity state,
    String mondayIso,
    String participantId,
    String fechaIso,
  ) {
    var s = ensureWeekDefaults(state, mondayIso);
    final semana = s.semanaDe(mondayIso)!;
    if (semana.participantes.any((p) => p.participanteId == participantId)) {
      return s;
    }
    final participantes = [
      ...semana.participantes,
      SemanaParticipanteEntity(participanteId: participantId, agregadoEn: fechaIso),
    ];
    return _setSemana(s, mondayIso, semana.copyWith(participantes: participantes));
  }

  ShiftsStateEntity removeWeekParticipant(
    ShiftsStateEntity state,
    String mondayIso,
    String participantId,
    String fechaIso,
  ) {
    var s = ensureWeekDefaults(state, mondayIso);
    final semana = s.semanaDe(mondayIso)!;
    final participantes = [
      for (final p in semana.participantes)
        if (p.participanteId == participantId) p.copyWith(retiradoEn: fechaIso) else p,
    ];
    return _setSemana(s, mondayIso, semana.copyWith(participantes: participantes));
  }

  // ── Generación del día actual ────────────────────────────────────────────

  /// Genera únicamente los periodos generables pendientes hasta [todayIso]
  /// (nunca futuros) de la semana [mondayIso]: el/los producto(s) semanales
  /// (una vez, el primer día generable) y los productos diarios día por día
  /// en orden cronológico, sin saltarse huecos si la app no se abrió un día.
  ShiftsStateEntity generateToday(
    ShiftsStateEntity state,
    String mondayIso,
    String todayIso,
  ) {
    var s = ensureWeekDefaults(state, mondayIso);
    final semana = s.semanaDe(mondayIso)!;
    if (WeekStateService.estadoDe(semana, todayIso) != EstadoSemana.enCurso) {
      return s;
    }

    for (final productoId in _productoIdsPorFrecuencia(s, esDiario: false)) {
      final actual = s.asignacionDe(productoId, mondayIso);
      if (actual?.locked ?? false) continue;
      if (actual?.participanteId == null) {
        s = autoAssignProducto(s, productoId, mondayIso);
      }
    }

    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      if (!AppDateUtils.esDiaGenerable(dayIso)) continue;
      if (dayIso.compareTo(todayIso) > 0) break;
      for (final productoId in _productoIdsPorFrecuencia(s, esDiario: true)) {
        final actual = s.asignacionDe(productoId, dayIso);
        if (actual?.locked ?? false) continue;
        if (actual?.participanteId == null) {
          s = autoAssignProducto(s, productoId, dayIso);
        }
      }
    }
    return s;
  }

  // ── Asignación de un producto en un periodo ─────────────────────────────

  /// Asigna un producto en un periodo (fecha ISO para productos diarios,
  /// lunes ISO para semanales). Respeta el 🔒 del periodo.
  ShiftsStateEntity autoAssignProducto(
    ShiftsStateEntity stateIn,
    String productoId,
    String periodoId,
  ) {
    final condicion = stateIn.condicionDe(productoId);
    if (condicion == null) return stateIn;

    final mondayIso = condicion.esDiario
        ? _mondayOfDay(periodoId)
        : periodoId;

    final state = ensureWeekDefaults(stateIn, mondayIso);

    final actual = state.asignacionDe(productoId, periodoId);
    if (actual?.locked ?? false) return state;

    List<String> pool;
    if (condicion.esDiario) {
      pool = state.presentesEn(periodoId);
      if (pool.length < condicion.minPresentes) {
        return _setAsignacion(
          state,
          productoId,
          periodoId,
          (actual ?? const AssignmentEntity()).copyWith(
            participanteId: null,
            warning: warnMinPresentes(condicion.minPresentes),
          ),
        );
      }
    } else {
      pool = _weekPresenceUnion(state, mondayIso);
      if (pool.isEmpty) {
        return _setAsignacion(
          state,
          productoId,
          periodoId,
          (actual ?? const AssignmentEntity()).copyWith(
            participanteId: null,
            warning: warnSemanaSinPresentes,
          ),
        );
      }
    }

    String? warning;

    final excluded = _applyExclusiones(state, productoId, condicion, periodoId, mondayIso, pool);
    pool = excluded.pool;
    warning ??= excluded.warning;
    if (pool.isEmpty) {
      return _setAsignacion(
        state,
        productoId,
        periodoId,
        (actual ?? const AssignmentEntity()).copyWith(
          participanteId: null,
          warning: warnSinCandidatos,
        ),
      );
    }

    if (condicion.evitaRepetirPeriodoAnterior) {
      final soft = _softExcludePeriodoAnterior(state, productoId, condicion, periodoId, mondayIso, pool);
      pool = soft.pool;
      warning ??= soft.warning;
    }

    if (condicion.esDiario) {
      pool = _softPreferLeastUsedThisWeek(state, productoId, mondayIso, pool);
    }

    // Fairness sin contar el pick vigente del propio periodo.
    final statsBase = _setAsignacion(
      state,
      productoId,
      periodoId,
      (actual ?? const AssignmentEntity()).copyWith(participanteId: null),
    );
    final stats = picker.computeStats(statsBase);
    final pickId = picker.pickFair(pool, stats.counts[productoId] ?? const {});
    return _setAsignacion(
      state,
      productoId,
      periodoId,
      (actual ?? const AssignmentEntity()).copyWith(participanteId: pickId, warning: warning),
    );
  }

  /// Sobrescritura manual (regla 8): siempre se permite, calcula la
  /// advertencia de toda regla que se rompa. Si el producto es semanal,
  /// libera y reasigna los productos diarios excluidos que queden en
  /// conflicto (sin 🔒).
  ShiftsStateEntity manualSetProducto(
    ShiftsStateEntity state,
    String productoId,
    String periodoId,
    String? participanteId,
  ) {
    final condicion = state.condicionDe(productoId);
    if (condicion == null) return state;
    final mondayIso = condicion.esDiario ? _mondayOfDay(periodoId) : periodoId;
    var s = ensureWeekDefaults(state, mondayIso);
    final actual = s.asignacionDe(productoId, periodoId) ?? const AssignmentEntity();
    final warning = participanteId == null
        ? null
        : _manualWarning(s, productoId, condicion, periodoId, mondayIso, participanteId);
    s = _setAsignacion(
      s,
      productoId,
      periodoId,
      actual.copyWith(participanteId: participanteId, warning: warning),
    );
    if (participanteId != null && !condicion.esDiario) {
      s = _resolveExclusionConflicts(s, productoId, mondayIso, participanteId);
    }
    return s;
  }

  ShiftsStateEntity setPresencia(
    ShiftsStateEntity state,
    String fechaIso,
    List<String> presentes,
  ) {
    var s = state.copyWith(
      presenciaPorDia: {...state.presenciaPorDia, fechaIso: presentes},
    );
    for (final productoId in _productoIdsPorFrecuencia(s, esDiario: true)) {
      final asignacion = s.asignacionDe(productoId, fechaIso);
      if (asignacion == null || asignacion.participanteId == null) continue;
      final condicion = s.condicionDe(productoId)!;
      final issues = <String>[];
      if (!presentes.contains(asignacion.participanteId)) {
        issues.add('El asignado ya no está presente.');
      }
      if (presentes.length < condicion.minPresentes) {
        issues.add('Hay menos de ${condicion.minPresentes} presentes.');
      }
      s = _setAsignacion(
        s,
        productoId,
        fechaIso,
        asignacion.copyWith(warning: issues.isEmpty ? null : issues.join(' ')),
      );
    }
    return s;
  }

  ShiftsStateEntity toggleLock(
    ShiftsStateEntity state,
    String productoId,
    String periodoId,
  ) {
    final actual = state.asignacionDe(productoId, periodoId);
    if (actual == null) return state;
    return _setAsignacion(state, productoId, periodoId, actual.copyWith(locked: !actual.locked));
  }

  // ── Internos ─────────────────────────────────────────────────────────────

  List<String> _weekPresenceUnion(ShiftsStateEntity state, String mondayIso) {
    final present = <String>{};
    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      if (!AppDateUtils.esDiaGenerable(dayIso)) continue;
      present.addAll(state.presentesEn(dayIso));
    }
    return [
      for (final p in state.participants)
        if (present.contains(p.id)) p.id,
    ];
  }

  ({List<String> pool, String? warning}) _applyExclusiones(
    ShiftsStateEntity state,
    String productoId,
    ProductConditionEntity condicion,
    String periodoId,
    String mondayIso,
    List<String> pool,
  ) {
    String? warning;
    var result = pool;
    for (final ex in state.exclusiones.where((e) => e.involucra(productoId))) {
      final otherId = ex.otro(productoId);
      final otherCondicion = state.condicionDe(otherId);
      if (otherCondicion == null) continue;

      if (!otherCondicion.esDiario) {
        // El otro producto es semanal/mensual: exclusión dura de quien ya
        // lo tenga esta semana (regla 4 original: gaseosa excluye a vasos).
        final otherAssigned = state.asignacionDe(otherId, mondayIso)?.participanteId;
        if (otherAssigned == null) continue;
        if (ex.dureza == ExclusionDureza.dura) {
          result = result.where((id) => id != otherAssigned).toList();
        } else {
          final soft = result.where((id) => id != otherAssigned).toList();
          if (soft.isNotEmpty) {
            result = soft;
          } else {
            warning ??= warnConflictoExclusion(otherId);
          }
        }
      } else if (ex.alcance == ExclusionAlcance.dia && condicion.esDiario) {
        final otherAssigned = state.asignacionDe(otherId, periodoId)?.participanteId;
        if (otherAssigned == null) continue;
        final soft = result.where((id) => id != otherAssigned).toList();
        if (soft.isNotEmpty) {
          result = soft;
        } else if (ex.dureza == ExclusionDureza.blanda) {
          warning ??= warnConflictoExclusion(otherId);
        }
      } else {
        // El otro producto es diario a escala de semana (caso vasos→gaseosa
        // original): solo se protege a quien ya tenga el otro producto en
        // un periodo BLOQUEADO de esta semana; el resto se resuelve después
        // vía `_resolveExclusionConflicts` cuando se fije este producto.
        final lockedOtherIds = <String>{
          for (final dayIso in AppDateUtils.weekDays(mondayIso))
            if (state.asignacionDe(otherId, dayIso)?.locked ?? false)
              if (state.asignacionDe(otherId, dayIso)?.participanteId != null)
                state.asignacionDe(otherId, dayIso)!.participanteId!,
        };
        final soft = result.where((id) => !lockedOtherIds.contains(id)).toList();
        if (soft.isNotEmpty) {
          result = soft;
        } else if (lockedOtherIds.isNotEmpty) {
          warning ??= warnConflictoExclusionBloqueado(otherId);
        }
      }
    }
    return (pool: result, warning: warning);
  }

  ({List<String> pool, String? warning}) _softExcludePeriodoAnterior(
    ShiftsStateEntity state,
    String productoId,
    ProductConditionEntity condicion,
    String periodoId,
    String mondayIso,
    List<String> pool,
  ) {
    List<String> soft;
    if (condicion.esDiario) {
      final prevId = state
          .asignacionDe(productoId, AppDateUtils.previousGenerableDay(periodoId))
          ?.participanteId;
      final nextId = state
          .asignacionDe(productoId, AppDateUtils.nextGenerableDay(periodoId))
          ?.participanteId;
      soft = pool.where((id) => id != prevId && id != nextId).toList();
    } else {
      final prevId = state
          .asignacionDe(productoId, AppDateUtils.previousMonday(mondayIso))
          ?.participanteId;
      soft = pool.where((id) => id != prevId).toList();
    }
    if (soft.isEmpty) return (pool: pool, warning: warnRepitePeriodoAnterior);
    return (pool: soft, warning: null);
  }

  List<String> _softPreferLeastUsedThisWeek(
    ShiftsStateEntity state,
    String productoId,
    String mondayIso,
    List<String> pool,
  ) {
    final asignacionesProducto =
        state.asignaciones[productoId] ?? const <String, AssignmentEntity>{};
    final counts = <String, int>{
      for (final id in pool) id: 0,
    };
    for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
      final id = asignacionesProducto[dayIso]?.participanteId;
      if (id != null && counts.containsKey(id)) {
        counts[id] = counts[id]! + 1;
      }
    }
    final min = counts.values.fold<int>(1 << 30, (a, b) => a < b ? a : b);
    final best = pool.where((id) => counts[id] == min).toList();
    return best.isEmpty ? pool : best;
  }

  String? _manualWarning(
    ShiftsStateEntity state,
    String productoId,
    ProductConditionEntity condicion,
    String periodoId,
    String mondayIso,
    String participanteId,
  ) {
    final issues = <String>[];
    for (final ex in state.exclusiones.where((e) => e.involucra(productoId))) {
      final otherId = ex.otro(productoId);
      final otherCondicion = state.condicionDe(otherId);
      if (otherCondicion == null) continue;
      if (!otherCondicion.esDiario) {
        if (state.asignacionDe(otherId, mondayIso)?.participanteId == participanteId) {
          issues.add('También tiene $otherId esta semana.');
        }
      } else if (condicion.esDiario &&
          state.asignacionDe(otherId, periodoId)?.participanteId == participanteId) {
        issues.add('También tiene $otherId el mismo día.');
      } else {
        for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
          if (state.asignacionDe(otherId, dayIso)?.participanteId == participanteId) {
            issues.add('Tiene $otherId en un día de esta semana.');
            break;
          }
        }
      }
    }
    if (condicion.evitaRepetirPeriodoAnterior) {
      if (condicion.esDiario) {
        if (state
                .asignacionDe(productoId, AppDateUtils.previousGenerableDay(periodoId))
                ?.participanteId ==
            participanteId) {
          issues.add('Tuvo este producto el periodo generable anterior.');
        }
        if (state
                .asignacionDe(productoId, AppDateUtils.nextGenerableDay(periodoId))
                ?.participanteId ==
            participanteId) {
          issues.add('Tiene este producto el periodo generable siguiente.');
        }
      } else if (state
              .asignacionDe(productoId, AppDateUtils.previousMonday(mondayIso))
              ?.participanteId ==
          participanteId) {
        issues.add('Tuvo este producto la semana pasada.');
      }
    }
    if (condicion.esDiario) {
      final presentes = state.presentesEn(periodoId);
      if (!presentes.contains(participanteId)) {
        issues.add('No está marcado como presente ese día.');
      }
      if (presentes.length < condicion.minPresentes) {
        issues.add('Hay menos de ${condicion.minPresentes} presentes.');
      }
    }
    return issues.isEmpty ? null : issues.join(' ');
  }

  /// Libera (y reintenta) los periodos diarios de productos excluidos que
  /// hayan quedado en conflicto tras fijar manualmente un producto semanal.
  ShiftsStateEntity _resolveExclusionConflicts(
    ShiftsStateEntity state,
    String productoId,
    String mondayIso,
    String participanteId,
  ) {
    var s = state;
    for (final ex in state.exclusiones.where(
      (e) => e.dureza == ExclusionDureza.dura && e.involucra(productoId),
    )) {
      final otherId = ex.otro(productoId);
      final otherCondicion = state.condicionDe(otherId);
      if (otherCondicion == null || !otherCondicion.esDiario) continue;
      for (final dayIso in AppDateUtils.weekDays(mondayIso)) {
        final asignacion = s.asignacionDe(otherId, dayIso);
        if (asignacion == null || asignacion.participanteId != participanteId) {
          continue;
        }
        if (asignacion.locked) {
          s = _setAsignacion(
            s,
            otherId,
            dayIso,
            asignacion.copyWith(warning: warnConflictoExclusionBloqueado(productoId)),
          );
        } else {
          s = _setAsignacion(s, otherId, dayIso, asignacion.copyWith(participanteId: null, warning: null));
          s = autoAssignProducto(s, otherId, dayIso);
        }
      }
    }
    return s;
  }

  List<String> _productoIdsPorFrecuencia(ShiftsStateEntity state, {required bool esDiario}) {
    return [
      for (final entry in state.condiciones.entries)
        if (entry.value.esDiario == esDiario) entry.key,
    ];
  }

  String _mondayOfDay(String dateIso) =>
      AppDateUtils.toIso(AppDateUtils.mondayOf(AppDateUtils.parseIso(dateIso)));

  ShiftsStateEntity _setAsignacion(
    ShiftsStateEntity state,
    String productoId,
    String periodoId,
    AssignmentEntity asignacion,
  ) {
    final porProducto = Map<String, AssignmentEntity>.of(
      state.asignaciones[productoId] ?? const {},
    );
    porProducto[periodoId] = asignacion;
    return state.copyWith(
      asignaciones: {...state.asignaciones, productoId: porProducto},
    );
  }

  ShiftsStateEntity _setSemana(
    ShiftsStateEntity state,
    String mondayIso,
    GeneratedWeekEntity semana,
  ) {
    return state.copyWith(semanas: {...state.semanas, mondayIso: semana});
  }
}
