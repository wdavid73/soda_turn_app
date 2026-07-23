import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/shifts_state_entity.dart';

/// Contrato de persistencia del estado completo.
///
/// El MVP lo implementa con shared_preferences; la fase 2 (Supabase) debe
/// implementar este mismo contrato sin tocar dominio ni presentación.
abstract class ShiftsRepository {
  /// Carga el estado guardado, o `null` si nunca se ha guardado.
  Future<Either<Failure, ShiftsStateEntity?>> load();

  Future<Either<Failure, Unit>> save(ShiftsStateEntity state);

  /// Materializa a `historico` las semanas ya completadas y limpia sus
  /// filas "vivas". No-op en implementaciones sin tablas separadas para
  /// histórico (ej. el respaldo local).
  Future<Either<Failure, Unit>> closeCompletedWeeks(String todayIso);

  /// Emite un evento cada vez que otro dispositivo cambia la semana activa.
  /// Stream vacío en implementaciones sin soporte realtime (ej. local).
  Stream<void> watchChanges();
}
