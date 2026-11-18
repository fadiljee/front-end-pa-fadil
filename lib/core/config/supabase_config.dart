/// Konfigurasi terpusat Supabase yang dibaca dari `--dart-define`.
class SupabaseConfig {
  SupabaseConfig._();

  /// URL proyek Supabase (`--dart-define=SUPABASE_URL=https://xxx.supabase.co`).
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Anon key proyek Supabase (`--dart-define=SUPABASE_ANON_KEY=...`).
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Timeout standar untuk seluruh permintaan jaringan ke Supabase.
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Bernilai `true` apabila kredensial Supabase telah disediakan saat build/run.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
