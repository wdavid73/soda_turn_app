import '../entities/turnos_state_entity.dart';

/// Elimina a la persona de la lista; su historial en assignments/weeklyVasos
/// se conserva para no distorsionar las estadísticas pasadas.
class RemoveParticipantUseCase {
  const RemoveParticipantUseCase();

  TurnosStateEntity call(TurnosStateEntity state, String id) {
    return state.copyWith(
      participants: state.participants.where((p) => p.id != id).toList(),
    );
  }
}
