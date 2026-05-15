/// Конфигурация из `--dart-define` (см. README).
class AppConfig {
  const AppConfig({required this.apiBaseUrl});

  /// Базовый URL API **без** завершающего слэша, например:
  /// `http://10.0.2.2:8000/api/v1` для эмулятора Android.
  final String apiBaseUrl;

  static AppConfig? _instance;

  static AppConfig get instance =>
      _instance ??= AppConfig(apiBaseUrl: _readBaseUrl());

  /// Для тестов.
  static void overrideForTest(AppConfig config) {
    _instance = config;
  }

  static void clearOverride() {
    _instance = null;
  }

  static String _readBaseUrl() {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/$'), '');
    return 'http://10.0.2.2:8000/api/v1';
  }
}
