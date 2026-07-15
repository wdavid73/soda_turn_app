import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/turnos_state_entity.dart';

/// Contrato de persistencia del estado completo.
///
/// El MVP lo implementa con shared_preferences; la fase 2 (Supabase) debe
/// implementar este mismo contrato sin tocar dominio ni presentación.
abstract class TurnosRepository {
  /// Carga el estado guardado, o `null` si nunca se ha guardado.
  Future<Either<Failure, TurnosStateEntity?>> load();

  Future<Either<Failure, Unit>> save(TurnosStateEntity state);
}
