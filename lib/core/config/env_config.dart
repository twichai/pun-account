import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized, type-safe environment configuration for the Pun Account Flutter client.
/// Reads from:
/// 1. flutter_dotenv (.env asset file)
/// 2. Dart define (--dart-define / --dart-define-from-file=.env)
/// 3. Safe platform-aware fallbacks
class EnvConfig {
  const EnvConfig._();

  static Future<void> init({String fileName = '.env'}) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      // Gracefully continue with String.fromEnvironment or default fallbacks
      // Useful during automated tests or when .env asset is omitted
    }
  }

  static String? _get(String key) {
    if (dotenv.isInitialized) {
      return dotenv.maybeGet(key);
    }
    return null;
  }

  /// App Environment: 'development', 'staging', 'production'
  static String get appEnv {
    return _get('APP_ENV') ??
        const String.fromEnvironment('APP_ENV', defaultValue: 'development');
  }

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';

  /// Backend API Base URL
  static String get apiBaseUrl {
    final configured =
        _get('API_BASE_URL') ??
        const String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured;
    }
    return _defaultBaseUrl();
  }

  /// Network Timeout in milliseconds
  static int get apiTimeoutMs {
    final raw =
        _get('API_TIMEOUT_MS') ??
        const String.fromEnvironment('API_TIMEOUT_MS', defaultValue: '10000');
    return int.tryParse(raw) ?? 10000;
  }

  /// Google OAuth Web Client ID
  static String get googleClientIdWeb {
    return _get('GOOGLE_CLIENT_ID_WEB') ??
        const String.fromEnvironment('GOOGLE_CLIENT_ID_WEB', defaultValue: '');
  }

  /// Google OAuth iOS / macOS Client ID
  static String get googleClientIdIos {
    return _get('GOOGLE_CLIENT_ID_IOS') ??
        const String.fromEnvironment('GOOGLE_CLIENT_ID_IOS', defaultValue: '');
  }

  /// Google OAuth Android Client ID
  static String get googleClientIdAndroid {
    return _get('GOOGLE_CLIENT_ID_ANDROID') ??
        const String.fromEnvironment(
          'GOOGLE_CLIENT_ID_ANDROID',
          defaultValue: '',
        );
  }

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api/v1';
      }
    } catch (_) {
      // Fallback if Platform is unsupported
    }
    return 'http://127.0.0.1:8080/api/v1';
  }
}
