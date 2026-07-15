/// Fallos de dominio que cruzan capas envueltos en `Either<Failure, T>`.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

/// Error de lectura/escritura en el almacenamiento local.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
