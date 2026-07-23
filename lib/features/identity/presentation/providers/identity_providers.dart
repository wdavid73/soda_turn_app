import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shifts/presentation/providers/shifts_providers.dart';

/// Quién es la persona dueña de este teléfono, para poder mandarle push
/// notifications ("hoy te toca"). No es autenticación: es una preferencia
/// local, consistente con que todo el equipo ya confía en todos (ver
/// docs/06-supabase-roadmap.md, "Why there's no authentication").
class MyParticipantIdNotifier extends StateNotifier<String?> {
  static const _key = 'sodaturn_my_participant_id';

  final SharedPreferences prefs;

  MyParticipantIdNotifier(this.prefs) : super(prefs.getString(_key));

  Future<void> set(String participantId) async {
    state = participantId;
    await prefs.setString(_key, participantId);
  }

  Future<void> clear() async {
    state = null;
    await prefs.remove(_key);
  }
}

final myParticipantIdProvider =
    StateNotifierProvider<MyParticipantIdNotifier, String?>(
      (ref) => MyParticipantIdNotifier(ref.read(sharedPreferencesProvider)),
    );
