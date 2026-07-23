import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pide permiso de notificaciones y sincroniza el token FCM de este
/// dispositivo con `push_tokens`, asociado al participante elegido en
/// `WhoAreYouSheet`. Silencioso ante cualquier falla (permiso denegado,
/// plataforma sin Firebase configurado, etc.): el push es un extra, nunca
/// debe tumbar el flujo normal de la app.
class PushTokenService {
  final SupabaseClient client;

  const PushTokenService(this.client);

  Future<void> registerFor(String participantId) async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await FirebaseMessaging.instance.getToken();
      debugPrint('SodaTurn FCM token: $token');
      if (token == null) return;
      await _upsert(participantId, token);
    } catch (_) {}
  }

  /// Reasocia el token actual si rota (ver `FirebaseMessaging.onTokenRefresh`).
  Future<void> onTokenRefreshed(String participantId, String token) async {
    try {
      await _upsert(participantId, token);
    } catch (_) {}
  }

  Future<void> _upsert(String participantId, String token) => client
      .from('push_tokens')
      .upsert({
        'participante_id': participantId,
        'token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'token');
}
