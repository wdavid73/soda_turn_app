import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../shifts/presentation/providers/shifts_providers.dart';
import '../../data/push_token_service.dart';

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

/// `null` si Supabase no está configurado (no hay dónde registrar el token)
/// o en web, donde el push queda fuera por diseño en esta fase (FCM web
/// requiere VAPID + service worker; ver plan del port a web).
final pushTokenServiceProvider = Provider<PushTokenService?>(
  (ref) => !kIsWeb && SupabaseConfig.isConfigured
      ? PushTokenService(Supabase.instance.client)
      : null,
);
