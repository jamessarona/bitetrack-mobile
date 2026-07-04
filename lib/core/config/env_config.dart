import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._({
    required this.appName,
    required this.apiBaseUrl,
    required this.realtimeUrl,
    required this.googleMapsApiKey,
    required this.googleClientId,
    required this.enableAnalytics,
    required this.environment,
  });

  final String appName;
  final String apiBaseUrl;
  final String realtimeUrl;
  final String googleMapsApiKey;
  final String googleClientId;
  final bool enableAnalytics;
  final String environment;

  static EnvConfig? _instance;

  static EnvConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('EnvConfig not initialized. Call EnvConfig.load() first.');
    }
    return config;
  }

  static Future<EnvConfig> load() async {
    const environment = String.fromEnvironment('ENV', defaultValue: 'development');
    await dotenv.load(fileName: 'env/env.$environment');

    _instance = EnvConfig._(
      appName: dotenv.get('APP_NAME', fallback: 'BiteTrack'),
      apiBaseUrl: dotenv.get('API_BASE_URL'),
      realtimeUrl: dotenv.get('REALTIME_URL'),
      googleMapsApiKey: dotenv.get('GOOGLE_MAPS_API_KEY', fallback: ''),
      googleClientId: dotenv.get('GOOGLE_CLIENT_ID', fallback: ''),
      enableAnalytics: dotenv.get('ENABLE_ANALYTICS', fallback: 'false') == 'true',
      environment: environment,
    );

    return _instance!;
  }
}
