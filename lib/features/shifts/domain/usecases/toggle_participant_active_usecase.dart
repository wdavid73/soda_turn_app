import '../entities/shifts_state_entity.dart';

/// Inactivar conserva el historial (vacaciones, ausencias largas).
class ToggleParticipantActiveUseCase {
  const ToggleParticipantActiveUseCase();

  ShiftsStateEntity call(ShiftsStateEntity state, String id) {
    return state.copyWith(
      participants: [
        for (final p in state.participants)
          if (p.id == id) p.copyWith(active: !p.active) else p,
      ],
    );
  }
}
