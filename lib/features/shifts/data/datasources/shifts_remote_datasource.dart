import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/app_date_utils.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/generated_week_entity.dart';
import '../../domain/entities/shifts_state_entity.dart';
import '../../domain/services/week_state_service.dart';
import '../models/product_condition_model.dart';
import '../models/participant_model.dart';
import '../models/product_exclusion_model.dart';
import '../models/product_model.dart';
import '../models/generated_week_model.dart';

/// Fuente remota: lee/escribe el agregado completo en Supabase, tabla por
/// tabla, y lo recompone en la misma forma que usa `ShiftsEngine`.
///
/// `historico` se pliega dentro de `asignaciones` al cargar, para que
/// `FairPickerService.computeStats` (que solo mira `state.asignaciones`)
/// vea el historial completo sin necesitar una fuente aparte. `save` solo
/// escribe en las tablas "vivas" (`asignacion_diaria`/`asignacion_semanal`,
/// `presencia_dia`, `semana_generada`/`semana_participantes`) las semanas
/// que el propio estado en memoria conoce; nunca reescribe `historico`
/// (append-only, se materializa aparte cuando una semana se cierra).
class ShiftsRemoteDatasource {
  final SupabaseClient client;

  const ShiftsRemoteDatasource(this.client);

  Future<ShiftsStateEntity> load() async {
    final participantesRows = await client.from('participantes').select();
    final productosRows = await client.from('productos').select();
    final condicionesRows = await client.from('condicion_producto').select();
    final exclusionesRows = await client.from('producto_exclusiones').select();
    final semanasRows = await client.from('semana_generada').select();
    final semanaParticipantesRows = await client
        .from('semana_participantes')
        .select();
    final presenciaRows = await client.from('presencia_dia').select();
    final asignacionDiariaRows = await client.from('asignacion_diaria').select();
    final asignacionSemanalRows = await client.from('asignacion_semanal').select();
    final historicoRows = await client.from('historico').select();

    final mondayOfSemanaId = <String, String>{
      for (final row in semanasRows)
        row['id'] as String: row['monday'] as String,
    };

    final semanas = <String, GeneratedWeekEntity>{};
    for (final row in semanasRows) {
      final model = GeneratedWeekModel.fromRow(row);
      semanas[model.monday] = GeneratedWeekEntity(
        monday: model.monday,
        friday: model.friday,
        estado: model.estado,
      );
    }
    for (final row in semanaParticipantesRows) {
      final mondayIso = mondayOfSemanaId[row['semana_id'] as String];
      if (mondayIso == null) continue;
      final semana = semanas[mondayIso];
      if (semana == null) continue;
      semanas[mondayIso] = semana.copyWith(
        participantes: [
          ...semana.participantes,
          SemanaParticipanteModel.fromRow(row).toEntity(),
        ],
      );
    }

    final presenciaPorDia = <String, List<String>>{};
    for (final row in presenciaRows) {
      if (row['presente'] == false) continue;
      final fecha = row['fecha'] as String;
      (presenciaPorDia[fecha] ??= []).add(row['participante_id'] as String);
    }

    final asignaciones = <String, Map<String, AssignmentEntity>>{};
    for (final row in asignacionDiariaRows) {
      final productoId = row['producto_id'] as String;
      final fecha = row['fecha'] as String;
      (asignaciones[productoId] ??= {})[fecha] = AssignmentEntity(
        participanteId: row['participante_id'] as String?,
        locked: row['locked'] as bool? ?? false,
        warning: row['warning'] as String?,
      );
    }
    for (final row in asignacionSemanalRows) {
      final productoId = row['producto_id'] as String;
      final mondayIso = mondayOfSemanaId[row['semana_id'] as String];
      if (mondayIso == null) continue;
      (asignaciones[productoId] ??= {})[mondayIso] = AssignmentEntity(
        participanteId: row['participante_id'] as String?,
        locked: row['locked'] as bool? ?? false,
        warning: row['warning'] as String?,
      );
    }
    // Histórico solo llena huecos que las tablas "vivas" no cubran (una
    // semana ya completada no tiene fila en asignacion_diaria/semanal).
    for (final row in historicoRows) {
      final productoId = row['producto_id'] as String;
      final periodoId = row['fecha'] as String;
      final porProducto = asignaciones[productoId] ??= {};
      porProducto.putIfAbsent(
        periodoId,
        () => AssignmentEntity(
          participanteId: row['participante_id'] as String?,
          warning: row['warning'] as String?,
        ),
      );
    }

    return ShiftsStateEntity(
      participants: participantesRows
          .map((row) => ParticipantModel.fromRow(row).toEntity())
          .toList(),
      productos: productosRows
          .map((row) => ProductModel.fromRow(row).toEntity())
          .toList(),
      condiciones: {
        for (final row in condicionesRows)
          (row['producto_id'] as String):
              ProductConditionModel.fromRow(row).toEntity(),
      },
      asignaciones: asignaciones,
      presenciaPorDia: presenciaPorDia,
      exclusiones: exclusionesRows
          .map((row) => ProductExclusionModel.fromRow(row).toEntity())
          .toList(),
      semanas: semanas,
    );
  }

  Future<void> save(ShiftsStateEntity state) async {
    if (state.participants.isNotEmpty) {
      await client
          .from('participantes')
          .upsert(state.participants.map((p) => ParticipantModel.fromEntity(p).toRow()).toList());
    }
    if (state.productos.isNotEmpty) {
      await client
          .from('productos')
          .upsert(state.productos.map((p) => ProductModel.fromEntity(p).toRow()).toList());
    }
    if (state.condiciones.isNotEmpty) {
      await client.from('condicion_producto').upsert(
        state.condiciones.values
            .map((c) => ProductConditionModel.fromEntity(c).toRow())
            .toList(),
        onConflict: 'producto_id',
      );
    }
    if (state.exclusiones.isNotEmpty) {
      await client.from('producto_exclusiones').upsert(
        state.exclusiones.map((e) => ProductExclusionModel.fromEntity(e).toRow()).toList(),
        onConflict: 'producto_a,producto_b',
      );
    }

    for (final entry in state.semanas.entries) {
      await _saveSemana(entry.key, entry.value, state);
    }
  }

  Future<void> _saveSemana(
    String mondayIso,
    GeneratedWeekEntity semana,
    ShiftsStateEntity state,
  ) async {
    final semanaRow = await client
        .from('semana_generada')
        .upsert(
          {'monday': mondayIso, ...GeneratedWeekModel(
            monday: mondayIso,
            friday: semana.friday,
            estado: semana.estado,
          ).toRow()},
          onConflict: 'monday',
        )
        .select('id')
        .single();
    final semanaId = semanaRow['id'] as String;

    if (semana.participantes.isNotEmpty) {
      await client.from('semana_participantes').upsert([
        for (final p in semana.participantes)
          {'semana_id': semanaId, ...SemanaParticipanteModel.fromEntity(p).toRow()},
      ], onConflict: 'semana_id,participante_id');
    }

    final presentes = state.presenciaPorDia.entries.where(
      (e) => e.key.compareTo(mondayIso) >= 0 && e.key.compareTo(semana.friday) <= 0,
    );
    for (final entry in presentes) {
      if (entry.value.isEmpty) continue;
      await client.from('presencia_dia').upsert([
        for (final participanteId in entry.value)
          {
            'semana_id': semanaId,
            'fecha': entry.key,
            'participante_id': participanteId,
            'presente': true,
          },
      ], onConflict: 'semana_id,fecha,participante_id');
    }

    // Solo se reescriben las tablas "vivas": semanas ya completadas quedan
    // como responsabilidad de la materialización a `historico`, no de este
    // método (ver `TurnosMigrationTool`/tarea de cierre de semana).
    if (semana.estado == EstadoSemana.completada) return;

    for (final productoEntry in state.asignaciones.entries) {
      final productoId = productoEntry.key;
      final condicion = state.condicionDe(productoId);
      if (condicion == null) continue;
      if (condicion.esDiario) {
        final rows = [
          for (final e in productoEntry.value.entries)
            if (e.key.compareTo(mondayIso) >= 0 && e.key.compareTo(semana.friday) <= 0)
              {
                'semana_id': semanaId,
                'producto_id': productoId,
                'fecha': e.key,
                'participante_id': e.value.participanteId,
                'locked': e.value.locked,
                'warning': e.value.warning,
              },
        ];
        if (rows.isNotEmpty) {
          await client
              .from('asignacion_diaria')
              .upsert(rows, onConflict: 'semana_id,producto_id,fecha');
        }
      } else if (productoEntry.value.containsKey(mondayIso)) {
        final a = productoEntry.value[mondayIso]!;
        await client.from('asignacion_semanal').upsert({
          'semana_id': semanaId,
          'producto_id': productoId,
          'participante_id': a.participanteId,
          'locked': a.locked,
          'warning': a.warning,
        }, onConflict: 'semana_id,producto_id');
      }
    }
  }

  /// Materializa a `historico` toda semana cuyo estado real (calculado con
  /// [WeekStateService], no la columna cache) sea [EstadoSemana.completada]
  /// y todavía tenga filas en las tablas "vivas". Idempotente: una semana ya
  /// materializada no tiene filas vivas, así que una segunda pasada no
  /// encuentra nada que reprocesar.
  Future<void> closeCompletedWeeks(String todayIso) async {
    final semanasRows = await client.from('semana_generada').select();

    for (final row in semanasRows) {
      final semanaId = row['id'] as String;
      final mondayIso = row['monday'] as String;
      final fridayIso = row['friday'] as String;
      final semana = GeneratedWeekEntity(monday: mondayIso, friday: fridayIso);
      if (WeekStateService.estadoDe(semana, todayIso) != EstadoSemana.completada) {
        continue;
      }

      final diariaRows = await client
          .from('asignacion_diaria')
          .select()
          .eq('semana_id', semanaId);
      final semanalRows = await client
          .from('asignacion_semanal')
          .select()
          .eq('semana_id', semanaId);
      if (diariaRows.isEmpty && semanalRows.isEmpty) continue;

      final presenciaRows = await client
          .from('presencia_dia')
          .select()
          .eq('semana_id', semanaId);
      final presentesPorFecha = <String, List<String>>{};
      for (final p in presenciaRows) {
        if (p['presente'] == false) continue;
        (presentesPorFecha[p['fecha'] as String] ??= []).add(
          p['participante_id'] as String,
        );
      }
      final presentesUnionSemana = <String>{
        for (final dayIso in AppDateUtils.weekDays(mondayIso))
          ...?presentesPorFecha[dayIso],
      };

      final historicoRows = [
        for (final r in diariaRows)
          {
            'semana_id': semanaId,
            'fecha': r['fecha'],
            'producto_id': r['producto_id'],
            'participante_id': r['participante_id'],
            'warning': r['warning'],
            'presentes_snapshot': presentesPorFecha[r['fecha'] as String] ?? const [],
          },
        for (final r in semanalRows)
          {
            'semana_id': semanaId,
            'fecha': mondayIso,
            'producto_id': r['producto_id'],
            'participante_id': r['participante_id'],
            'warning': r['warning'],
            'presentes_snapshot': presentesUnionSemana.toList(),
          },
      ];

      if (historicoRows.isNotEmpty) {
        await client
            .from('historico')
            .upsert(historicoRows, onConflict: 'semana_id,fecha,producto_id');
      }

      await client.from('asignacion_diaria').delete().eq('semana_id', semanaId);
      await client.from('asignacion_semanal').delete().eq('semana_id', semanaId);
      await client
          .from('semana_generada')
          .update({'estado': 'completada'})
          .eq('id', semanaId);
    }
  }
}
