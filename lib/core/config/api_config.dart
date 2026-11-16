/// Konfigurasi terpusat untuk endpoint API dan parameter jaringan aplikasi.
class ApiConfig {
  ApiConfig._();

  /// Base URL API yang dapat disetel saat build via `--dart-define=API_BASE_URL=...`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api',
  );

  /// Versi aplikasi yang dikirim pada header `X-App-Version`.
  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.1.0',
  );

  /// Timeout standar untuk seluruh permintaan HTTP.
  static const Duration requestTimeout = Duration(seconds: 20);

  /// Membangun [Uri] dari path relatif (mis. `/login` atau `login`).
  static Uri endpoint(String path) {
    final normalizedBase =
        baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }
}
