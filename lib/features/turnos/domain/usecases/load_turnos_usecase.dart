import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/turnos_state_entity.dart';
import '../repositories/turnos_repository.dart';

/// Carga el estado guardado; si no existe, arranca con los participantes
/// iniciales del grupo.
class LoadTurnosUseCase {
  final TurnosRepository repository;

  const LoadTurnosUseCase(this.repository);

  Future<Either<Failure, TurnosStateEntity>> call() async {
    final result = await repository.load();
    return result.map((state) => state ?? TurnosStateEntity.seed());
  }
}
