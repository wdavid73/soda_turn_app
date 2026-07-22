import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/shifts_state_entity.dart';
import '../../domain/repositories/shifts_repository.dart';
import '../datasources/shifts_local_datasource.dart';
import '../datasources/shifts_remote_datasource.dart';
import '../models/shifts_state_model.dart';

/// Implementa el mismo contrato que `ShiftsRepositoryImpl` (local), pero
/// contra Supabase. `shared_preferences` se usa solo como respaldo de
/// arranque offline: si la red falla, `load()` cae al último estado
/// guardado localmente en vez de dejar la app sin datos (ver estrategia de
/// sync en docs/06-roadmap-supabase.md, fase "remoto como fuente de verdad").
class ShiftsSupabaseRepository implements ShiftsRepository {
  final ShiftsRemoteDatasource remoteDatasource;
  final ShiftsLocalDatasource localBackup;

  const ShiftsSupabaseRepository(this.remoteDatasource, this.localBackup);

  @override
  Future<Either<Failure, ShiftsStateEntity?>> load() async {
    try {
      final state = await remoteDatasource.load();
      unawaited(_backupLocally(state));
      return Right(state);
    } catch (e) {
      try {
        final raw = await localBackup.read();
        if (raw == null || raw.isEmpty) return const Right(null);
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return Right(ShiftsStateModel.fromJson(json).toEntity());
      } catch (_) {
        return Left(
          ServerFailure(
            'No se pudo cargar desde Supabase ni desde el respaldo local: $e',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> save(ShiftsStateEntity state) async {
    try {
      await remoteDatasource.save(state);
      await _backupLocally(state);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('No se pudo guardar en Supabase: $e'));
    }
  }

  Future<void> _backupLocally(ShiftsStateEntity state) async {
    try {
      final raw = jsonEncode(ShiftsStateModel.fromEntity(state).toJson());
      await localBackup.write(raw);
    } catch (_) {
      // El respaldo local es best-effort; un fallo acá no debe tumbar el
      // flujo principal contra Supabase.
    }
  }
}
