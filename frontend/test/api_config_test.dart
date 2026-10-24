import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/api_config.dart';

void main() {
  group('ApiConfig Tests', () {
    tearDown(() {
      ApiConfig.resetBaseUrl();
    });

    test('Default baseUrl contains correct port and prefix', () {
      final url = ApiConfig.baseUrl;
      expect(url, contains(':5000'));
      expect(url, endsWith('/api/v1'));
    });

    test('Custom baseUrl override takes precedence', () {
      ApiConfig.setCustomBaseUrl('https://api.inhercue.example.com/api/v1');
      expect(ApiConfig.baseUrl, equals('https://api.inhercue.example.com/api/v1'));
    });

    test('Endpoint constants have leading slashes', () {
      expect(ApiConfig.healthEndpoint, startsWith('/'));
      expect(ApiConfig.registerEndpoint, startsWith('/'));
      expect(ApiConfig.loginEndpoint, startsWith('/'));
      expect(ApiConfig.meEndpoint, startsWith('/'));
    });
  });
}
