import '../repositories/shifts_repository.dart';

/// Expone el stream de cambios remotos de la semana activa (ver
/// `ShiftsRemoteDatasource.watchChanges`), para que el ViewModel recargue
/// el estado cuando otro dispositivo modifica algo.
class WatchShiftsChangesUseCase {
  final ShiftsRepository repository;

  const WatchShiftsChangesUseCase(this.repository);

  Stream<void> call() => repository.watchChanges();
}
