import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/shifts_repository.dart';

/// Dispara la materialización de semanas completadas a `historico` (ver
/// `ShiftsRemoteDatasource.closeCompletedWeeks`). Se llama al arrancar la
/// app, antes de `load()`, para que la carga ya vea el estado consolidado.
class CloseCompletedWeeksUseCase {
  final ShiftsRepository repository;

  const CloseCompletedWeeksUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String todayIso) =>
      repository.closeCompletedWeeks(todayIso);
}
