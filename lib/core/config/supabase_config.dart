/// Credenciales de Supabase.
///
/// Para conectar la app a tu propio backend:
/// 1. Crea un proyecto en https://supabase.com.
/// 2. Corre las migraciones de `supabase/migrations/` (Supabase CLI o
///    pegándolas en el SQL Editor del dashboard, en orden).
/// 3. En el dashboard: Settings → API → copia "Project URL" y "anon public"
///    y reemplaza los dos placeholders de abajo.
///
/// No hay autenticación en esta fase (un solo grupo compartido, ver
/// docs/06-roadmap-supabase.md), así que no hace falta nada más para
/// arrancar. Si el repositorio llega a ser público, considera mover estos
/// valores a `--dart-define` en vez de dejarlos hardcodeados en git.
class SupabaseConfig {
  SupabaseConfig._();

  static const String _placeholderUrl = 'https://your-project.supabase.co';
  static const String _placeholderAnonKey = 'your-anon-key';

  static const String url = 'https://ataygcxcaizycoueujwz.supabase.co';
  static const String anonKey =
      'sb_publishable_pfNYdE--WrRfu9p8HXmbAA_tdwm4qir';

  /// `true` mientras sigan los placeholders sin reemplazar.
  static bool get isConfigured =>
      url != _placeholderUrl && anonKey != _placeholderAnonKey;
}
