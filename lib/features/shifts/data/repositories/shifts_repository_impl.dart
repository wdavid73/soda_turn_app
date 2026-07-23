import 'dart:convert';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/shifts_state_entity.dart';
import '../../domain/repositories/shifts_repository.dart';
import '../datasources/shifts_local_datasource.dart';
import '../models/shifts_state_model.dart';

class ShiftsRepositoryImpl implements ShiftsRepository {
  final ShiftsLocalDatasource localDatasource;

  const ShiftsRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, ShiftsStateEntity?>> load() async {
    try {
      final raw = await localDatasource.read();
      if (raw == null || raw.isEmpty) return const Right(null);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return Right(ShiftsStateModel.fromJson(json).toEntity());
    } catch (e) {
      return Left(CacheFailure('No se pudo leer el estado guardado: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> save(ShiftsStateEntity state) async {
    try {
      final raw = jsonEncode(ShiftsStateModel.fromEntity(state).toJson());
      await localDatasource.write(raw);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('No se pudo guardar el estado: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> closeCompletedWeeks(String todayIso) async =>
      const Right(unit);

  @override
  Stream<void> watchChanges() => const Stream.empty();
}
