import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/api_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/data/services/auth_api_service.dart';
import 'package:frontend/data/services/health_api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient & Services Unit Tests', () {
    setUp(() {
      ApiConfig.setCustomBaseUrl('http://test-server/api/v1');
    });

    tearDown(() {
      ApiConfig.resetBaseUrl();
    });

    test('HealthApiService returns healthy model on 200 response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/v1/health'));
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'HerSignal API is operational',
            'data': {
              'service': 'inHercue API',
              'status': 'healthy',
              'environment': 'test',
              'database': {'status': 'connected'},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(client: mockClient);
      final healthService = HealthApiService(client: apiClient);

      final result = await healthService.checkHealth();
      expect(result.isHealthy, isTrue);
      expect(result.status, equals('healthy'));
      expect(result.dbStatus, equals('connected'));
    });

    test(
      'AuthApiService.register throws DuplicateEmailException on 409',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'error': {
                'code': 'DUPLICATE_EMAIL',
                'message': 'An account with this email address already exists.',
                'details': [
                  {
                    'field': 'email',
                    'issue': 'Email address is already registered.',
                  },
                ],
              },
            }),
            409,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final authService = AuthApiService(client: apiClient);

        expect(
          () => authService.register(
            name: 'Priya',
            email: 'duplicate@example.com',
            password: 'Password123!',
          ),
          throwsA(
            isA<DuplicateEmailException>().having(
              (e) => e.code,
              'code',
              equals('DUPLICATE_EMAIL'),
            ),
          ),
        );
      },
    );

    test(
      'AuthApiService.login throws InvalidCredentialsException on 401',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'error': {
                'code': 'INVALID_CREDENTIALS',
                'message': 'Invalid email or password.',
                'details': [],
              },
            }),
            401,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final authService = AuthApiService(client: apiClient);

        expect(
          () => authService.login(
            email: 'wrong@example.com',
            password: 'WrongPassword!',
          ),
          throwsA(isA<InvalidCredentialsException>()),
        );
      },
    );

    test(
      'AuthApiService.register throws ValidationException on 422 with details',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'success': false,
              'error': {
                'code': 'VALIDATION_ERROR',
                'message': 'Invalid registration input.',
                'details': [
                  {
                    'field': 'password',
                    'issue': 'Password must contain at least one number.',
                  },
                ],
              },
            }),
            422,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final authService = AuthApiService(client: apiClient);

        try {
          await authService.register(
            name: 'Priya',
            email: 'valid@example.com',
            password: 'nonumbersymbol!',
          );
          fail('Should have thrown ValidationException');
        } on ValidationException catch (e) {
          expect(e.statusCode, equals(422));
          expect(e.details.length, equals(1));
          expect(e.details.first.field, equals('password'));
        }
      },
    );

    test(
      'AuthApiService.getMe injects Bearer token in request header',
      () async {
        final mockClient = MockClient((request) async {
          expect(
            request.headers['Authorization'],
            equals('Bearer test_jwt_token_123'),
          );
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'User profile retrieved',
              'data': {
                'userId': '671a9101f82c4a001a111111',
                'email': 'user@example.com',
                'name': 'Priya Sharma',
                'onboardingCompleted': true,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(client: mockClient);
        final authService = AuthApiService(client: apiClient);

        final user = await authService.getMe('test_jwt_token_123');
        expect(user.userId, equals('671a9101f82c4a001a111111'));
        expect(user.name, equals('Priya Sharma'));
      },
    );
  });
}
