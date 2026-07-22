import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_date_utils.dart';

/// Migración única del blob local del MVP (`shared_preferences`, esquema
/// v1 hardcodeado a gaseosa/vasos) al esquema normalizado de Supabase.
///
/// No es un script de `dart run`: `shared_preferences` usa un canal de
/// plataforma, así que solo se puede leer desde dentro de la app (con el
/// binding de Flutter ya inicializado). Se ejecuta una sola vez, por
/// ejemplo desde un botón oculto en Ajustes o llamando
/// `LocalToSupabaseMigration(...).run()` desde `main()` detrás de un flag
/// temporal. Nunca borra el respaldo local.
///
/// Pasos (ver docs/06-roadmap-supabase.md):
/// 1. Participantes 1:1 desde `participants`.
/// 2. Siembra `productos`/`condicion_producto`/`producto_exclusiones` con
///    los valores de hoy (gaseosa diario/4/7000, vasos semanal_unico,
///    exclusión dura) — ya deberían existir vía
///    `supabase/migrations/0006_seed_productos_default.sql`; se
///    reinsertan con upsert por si la migración corre contra un proyecto
///    sin esas migraciones aplicadas todavía.
/// 3. Por cada lunes en `weeklyVasos`: `semana_generada` (`completada`) +
///    `semana_participantes` = unión de presentes de esa semana.
/// 4. Por cada día: `presencia_dia` + `historico` (gaseosa); por cada
///    lunes: `historico` (vasos). Nunca se pobla `asignacion_diaria`/
///    `asignacion_semanal` para semanas pasadas: esas tablas son solo para
///    la semana activa.
class LocalToSupabaseMigration {
  final SharedPreferences prefs;
  final SupabaseClient client;

  const LocalToSupabaseMigration(this.prefs, this.client);

  Future<MigrationReport> run() async {
    final raw = prefs.getString(AppConstants.storageKey);
    if (raw == null || raw.isEmpty) {
      return const MigrationReport(migrated: false, message: 'No hay datos locales que migrar.');
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final participants = (json['participants'] as List? ?? const [])
        .cast<Map<String, dynamic>>();
    final assignments = (json['assignments'] as Map<String, dynamic>? ?? const {});
    final weeklyVasos = (json['weeklyVasos'] as Map<String, dynamic>? ?? const {});

    await _seedParticipants(participants);
    await _seedProductos();

    var gaseosaHistorico = 0;
    var vasosHistorico = 0;

    for (final mondayIso in weeklyVasos.keys) {
      final weekDays = AppDateUtils.weekDays(mondayIso);
      final presentUnion = <String>{};
      for (final dayIso in weekDays) {
        final day = assignments[dayIso] as Map<String, dynamic>?;
        if (day == null) continue;
        presentUnion.addAll((day['present'] as List? ?? const []).map((e) => e.toString()));
      }

      final semanaRow = await client
          .from('semana_generada')
          .upsert({
            'monday': mondayIso,
            'friday': weekDays.last,
            'estado': 'completada',
          }, onConflict: 'monday')
          .select('id')
          .single();
      final semanaId = semanaRow['id'] as String;

      if (presentUnion.isNotEmpty) {
        await client.from('semana_participantes').upsert([
          for (final id in presentUnion)
            {'semana_id': semanaId, 'participante_id': id, 'agregado_en': mondayIso},
        ], onConflict: 'semana_id,participante_id');
      }

      for (final dayIso in weekDays) {
        final day = assignments[dayIso] as Map<String, dynamic>?;
        if (day == null) continue;
        final present = (day['present'] as List? ?? const []).map((e) => e.toString()).toList();
        if (present.isNotEmpty) {
          await client.from('presencia_dia').upsert([
            for (final id in present)
              {'semana_id': semanaId, 'fecha': dayIso, 'participante_id': id, 'presente': true},
          ], onConflict: 'semana_id,fecha,participante_id');
        }
        final gaseosaId = day['gaseosa']?.toString();
        if (gaseosaId != null) {
          await client.from('historico').upsert({
            'semana_id': semanaId,
            'fecha': dayIso,
            'producto_id': 'gaseosa',
            'participante_id': gaseosaId,
            'presentes_snapshot': present,
          }, onConflict: 'semana_id,fecha,producto_id');
          gaseosaHistorico++;
        }
      }

      final vasosPersonId = (weeklyVasos[mondayIso] as Map<String, dynamic>?)?['personId']
          ?.toString();
      if (vasosPersonId != null) {
        await client.from('historico').upsert({
          'semana_id': semanaId,
          'fecha': mondayIso,
          'producto_id': 'vasos',
          'participante_id': vasosPersonId,
          'presentes_snapshot': presentUnion.toList(),
        }, onConflict: 'semana_id,fecha,producto_id');
        vasosHistorico++;
      }
    }

    final verification = await _verifyCounts(assignments, weeklyVasos);
    return MigrationReport(
      migrated: true,
      message:
          'Migrados ${participants.length} participantes, $gaseosaHistorico '
          'días de gaseosa y $vasosHistorico semanas de vasos al histórico. '
          '$verification',
    );
  }

  Future<void> _seedParticipants(List<Map<String, dynamic>> participants) async {
    if (participants.isEmpty) return;
    await client.from('participantes').upsert([
      for (final p in participants)
        {
          'id': p['id'].toString(),
          'nombre': p['name']?.toString() ?? '',
          'activo': p['active'] as bool? ?? true,
        },
    ]);
  }

  Future<void> _seedProductos() async {
    await client.from('productos').upsert([
      {'id': 'gaseosa', 'nombre': 'Gaseosa'},
      {'id': 'vasos', 'nombre': 'Vasos'},
    ]);
    await client.from('condicion_producto').upsert([
      {
        'producto_id': 'gaseosa',
        'frecuencia': 'diario',
        'min_presentes': 4,
        'costo_cop': 7000,
        'evita_repetir_periodo_anterior': true,
      },
      {
        'producto_id': 'vasos',
        'frecuencia': 'semanal_unico',
        'min_presentes': 1,
        'evita_repetir_periodo_anterior': true,
      },
    ], onConflict: 'producto_id');
    await client.from('producto_exclusiones').upsert({
      'producto_a': 'gaseosa',
      'producto_b': 'vasos',
      'alcance': 'semana',
      'dureza': 'dura',
    }, onConflict: 'producto_a,producto_b');
  }

  /// Compara los conteos del blob local contra `historico` en Supabase;
  /// deben coincidir exactamente para dar la migración por buena.
  Future<String> _verifyCounts(
    Map<String, dynamic> assignments,
    Map<String, dynamic> weeklyVasos,
  ) async {
    final localGaseosa = <String, int>{};
    for (final day in assignments.values) {
      final id = (day as Map<String, dynamic>)['gaseosa']?.toString();
      if (id != null) localGaseosa[id] = (localGaseosa[id] ?? 0) + 1;
    }
    final localVasos = <String, int>{};
    for (final week in weeklyVasos.values) {
      final id = (week as Map<String, dynamic>)['personId']?.toString();
      if (id != null) localVasos[id] = (localVasos[id] ?? 0) + 1;
    }

    final remoteRows = await client
        .from('historico')
        .select('producto_id, participante_id');
    final remoteGaseosa = <String, int>{};
    final remoteVasos = <String, int>{};
    for (final row in remoteRows) {
      final id = row['participante_id'] as String?;
      if (id == null) continue;
      final target = row['producto_id'] == 'vasos' ? remoteVasos : remoteGaseosa;
      target[id] = (target[id] ?? 0) + 1;
    }

    final matches = _mapEquals(localGaseosa, remoteGaseosa) && _mapEquals(localVasos, remoteVasos);
    return matches
        ? 'Verificación OK: los conteos coinciden.'
        : 'ADVERTENCIA: los conteos locales y remotos no coinciden, revisa manualmente.';
  }

  bool _mapEquals(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}

class MigrationReport {
  final bool migrated;
  final String message;

  const MigrationReport({required this.migrated, required this.message});
}
