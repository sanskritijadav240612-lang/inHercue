import 'package:flutter/foundation.dart';

/// Centralized configuration for inHercue backend API connectivity.
/// Supports multi-device routing:
/// - Chrome / Web: http://localhost:5000/api/v1
/// - Android Emulator: http://10.0.2.2:5000/api/v1 (10.0.2.2 routes to host machine loopback)
/// - Desktop (Windows/macOS/Linux): http://localhost:5000/api/v1
/// - Physical Mobile Devices: Configurable via custom override or `--dart-define=API_URL=...`
class ApiConfig {
  ApiConfig._();

  /// Optional override for the base URL (useful for testing or LAN IP debugging).
  static String? _customBaseUrl;

  /// Sets a custom API base URL at runtime.
  static void setCustomBaseUrl(String? url) {
    _customBaseUrl = url;
  }

  /// Reset any custom base URL back to default.
  static void resetBaseUrl() {
    _customBaseUrl = null;
  }

  /// Default API version prefix.
  static const String apiPrefix = '/api/v1';

  /// Default port matching backend configuration (backend/src/config/env.js: process.env.PORT || 5000).
  static const int defaultPort = 5000;

  /// Resolves the active base URL for the current runtime platform.
  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }

    // Check for compile-time environment definition: flutter run --dart-define=API_URL=https://...
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Web and desktop connect directly to localhost:5000
    if (kIsWeb) {
      return 'http://localhost:$defaultPort$apiPrefix';
    }

    // Android emulator cannot reach host PC via localhost; Android uses 10.0.2.2
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$defaultPort$apiPrefix';
    }

    // iOS Simulator / macOS / Windows / Linux
    return 'http://localhost:$defaultPort$apiPrefix';
  }

  // ---------------------------------------------------------------------------
  // Implemented Endpoint Paths (relative to baseUrl)
  // ---------------------------------------------------------------------------
  static const String healthEndpoint = '/health';
  static const String registerEndpoint = '/auth/register';
  static const String loginEndpoint = '/auth/login';
  static const String meEndpoint = '/auth/me';
  static const String passportEndpoint = '/passport';
  static const String symptomsCheckinEndpoint = '/symptoms/check-in';
  static const String symptomsHistoryEndpoint = '/symptoms/history';
  static const String symptomsLatestEndpoint = '/symptoms/latest';
  static const String safetyTriageEndpoint = '/safety/triage';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
