import '../entities/shifts_state_entity.dart';

class RenameParticipantUseCase {
  const RenameParticipantUseCase();

  ShiftsStateEntity call(ShiftsStateEntity state, String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return state;
    return state.copyWith(
      participants: [
        for (final p in state.participants)
          if (p.id == id) p.copyWith(name: trimmed) else p,
      ],
    );
  }
}
