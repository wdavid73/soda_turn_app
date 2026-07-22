import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/routes/app_router.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/shifts/presentation/providers/shifts_providers.dart';

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
    );
  }
}
