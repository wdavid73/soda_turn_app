import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/shifts_state_entity.dart';
import '../repositories/shifts_repository.dart';

class SaveTurnosUseCase {
  final ShiftsRepository repository;

  const SaveTurnosUseCase(this.repository);

  Future<Either<Failure, Unit>> call(ShiftsStateEntity state) =>
      repository.save(state);
}
