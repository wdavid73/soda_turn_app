import '../../../../core/utils/slug_utils.dart';
import '../entities/participant_entity.dart';
import '../entities/turnos_state_entity.dart';

class AddParticipantUseCase {
  const AddParticipantUseCase();

  TurnosStateEntity call(TurnosStateEntity state, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return state;
    final id = uniqueSlug(
      slugify(trimmed),
      state.participants.map((p) => p.id),
    );
    return state.copyWith(
      participants: [
        ...state.participants,
        ParticipantEntity(id: id, name: trimmed),
      ],
    );
  }
}
