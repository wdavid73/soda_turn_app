import '../entities/turnos_state_entity.dart';

/// Inactivar conserva el historial (vacaciones, ausencias largas).
class ToggleParticipantActiveUseCase {
  const ToggleParticipantActiveUseCase();

  TurnosStateEntity call(TurnosStateEntity state, String id) {
    return state.copyWith(
      participants: [
        for (final p in state.participants)
          if (p.id == id) p.copyWith(active: !p.active) else p,
      ],
    );
  }
}
