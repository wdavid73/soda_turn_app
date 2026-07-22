import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/shifts_state_entity.dart';
import '../repositories/shifts_repository.dart';

/// Carga el estado guardado; si no existe, arranca con los participantes
/// iniciales del grupo.
class LoadTurnosUseCase {
  final ShiftsRepository repository;

  const LoadTurnosUseCase(this.repository);

  Future<Either<Failure, ShiftsStateEntity>> call() async {
    final result = await repository.load();
    return result.map((state) => state ?? ShiftsStateEntity.seed());
  }
}
