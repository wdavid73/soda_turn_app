import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/turnos_state_entity.dart';
import '../../domain/repositories/turnos_repository.dart';
import '../datasources/turnos_local_datasource.dart';
import '../models/turnos_state_model.dart';

class TurnosRepositoryImpl implements TurnosRepository {
  final TurnosLocalDatasource localDatasource;

  const TurnosRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, TurnosStateEntity?>> load() async {
    try {
      final raw = await localDatasource.read();
      if (raw == null || raw.isEmpty) return const Right(null);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Right(TurnosStateModel.fromJson(json).toEntity());
    } catch (e) {
      return Left(CacheFailure('No se pudo leer el estado guardado: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(TurnosStateEntity state) async {
    try {
      final raw = jsonEncode(TurnosStateModel.fromEntity(state).toJson());
      await localDatasource.write(raw);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('No se pudo guardar el estado: $e'));
    }
  }
}
