import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/turnos_state_entity.dart';
import '../repositories/turnos_repository.dart';

class SaveTurnosUseCase {
  final TurnosRepository repository;

  const SaveTurnosUseCase(this.repository);

  Future<Either<Failure, Unit>> call(TurnosStateEntity state) =>
      repository.save(state);
}
