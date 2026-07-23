import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/routes/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/identity/presentation/widgets/identity_gate.dart';
import 'features/shifts/presentation/providers/shifts_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Solo se conecta si ya pegaste tus credenciales reales en
  // lib/core/config/supabase_config.dart; si no, la app sigue funcionando
  // 100% local (shared_preferences) como en el MVP.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  // Solo Android tiene `firebase_options.dart` configurado hoy (ver
  // `lib/firebase_options.dart`, generado con `flutterfire configure`).
  // En otras plataformas (ej. Chrome en desarrollo) la app sigue andando,
  // simplemente sin push notifications.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const SodaTurnApp(),
    ),
  );
}

class SodaTurnApp extends ConsumerWidget {
  const SodaTurnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'SodaTurn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
      builder: (context, child) =>
          IdentityGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
