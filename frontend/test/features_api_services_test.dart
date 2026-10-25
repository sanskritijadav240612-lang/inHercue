import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/config/emergency_config.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/session_storage.dart';
import 'package:frontend/data/models/user_model.dart';
import 'package:frontend/data/services/passport_api_service.dart';
import 'package:frontend/data/services/safety_api_service.dart';
import 'package:frontend/data/services/symptom_api_service.dart';

class _MockApiClient extends ApiClient {
  Map<String, dynamic>? mockResponse;
  String? lastEndpoint;
  String? lastToken;
  Map<String, dynamic>? lastBody;

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    Map<String, String>? headers,
  }) async {
    lastEndpoint = endpoint;
    lastToken = token;
    return mockResponse ?? {'success': true, 'data': null};
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
  }) async {
    lastEndpoint = endpoint;
    lastToken = token;
    lastBody = body;
    return mockResponse ?? {'success': true, 'data': {}};
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? headers,
  }) async {
    lastEndpoint = endpoint;
    lastToken = token;
    lastBody = body;
    return mockResponse ?? {'success': true, 'data': {}};
  }
}

void main() {
  group('PassportApiService Tests', () {
    late _MockApiClient mockClient;
    late PassportApiService service;

    setUp(() {
      mockClient = _MockApiClient();
      service = PassportApiService(client: mockClient);
    });

    test('getPassport returns null when data is null or empty', () async {
      mockClient.mockResponse = {'success': true, 'data': null};
      final result = await service.getPassport('test-jwt');
      expect(result, isNull);
      expect(mockClient.lastEndpoint, '/passport');
      expect(mockClient.lastToken, 'test-jwt');
    });

    test('getPassport parses PassportModel correctly', () async {
      mockClient.mockResponse = {
        'success': true,
        'data': {
          'focus': 'Understand my cycle',
          'cycleType': 'Regular (26–32 days)',
          'averageCycleDays': 29,
          'typicalPeriodDurationDays': 5,
          'diagnosedConditions': ['PCOS'],
          'allergies': ['Penicillin'],
          'currentMedications': ['Inositol'],
        },
      };

      final result = await service.getPassport('test-jwt');
      expect(result, isNotNull);
      expect(result!.focus, 'Understand my cycle');
      expect(result.cycleType, 'Regular (26–32 days)');
      expect(result.averageCycleDays, 29);
      expect(result.diagnosedConditions, contains('PCOS'));
      expect(result.allergies, contains('Penicillin'));
      expect(result.currentMedications, contains('Inositol'));
    });

    test(
      'savePassport transmits updated parameters and parses response',
      () async {
        mockClient.mockResponse = {
          'success': true,
          'data': {
            'focus': 'Support my mental health',
            'cycleType': 'Sometimes irregular',
            'diagnosedConditions': ['Endometriosis'],
          },
        };

        final result = await service.savePassport(
          token: 'test-jwt',
          focus: 'Support my mental health',
          cycleType: 'Sometimes irregular',
          diagnosedConditions: ['Endometriosis'],
        );

        expect(mockClient.lastEndpoint, '/passport');
        expect(mockClient.lastToken, 'test-jwt');
        expect(mockClient.lastBody!['focus'], 'Support my mental health');
        expect(mockClient.lastBody!['cycleType'], 'Sometimes irregular');
        expect(result.focus, 'Support my mental health');
      },
    );
  });

  group('SymptomApiService Tests', () {
    late _MockApiClient mockClient;
    late SymptomApiService service;

    setUp(() {
      mockClient = _MockApiClient();
      service = SymptomApiService(client: mockClient);
    });

    test('saveCheckin posts formatted payload and parses result with safety assessment', () async {
      mockClient.mockResponse = {
        'success': true,
        'data': {
          'log': {
            '_id': 'symptom-001',
            'date': '2026-10-25',
            'flow': 'medium',
            'painScale': 4,
            'symptoms': [
              {'type': 'Cramps', 'severity': 'moderate'},
            ],
            'hydration': 'Good',
            'mood': 'Calm',
            'safetyAssessment': {
              'isEmergency': false,
              'triageLevel': 'ROUTINE',
              'advice': 'Routine self-care applies.',
            },
          },
        },
      };

      final result = await service.saveCheckin(
        token: 'test-jwt',
        date: '2026-10-25',
        flow: 'medium',
        painScale: 4,
        symptoms: [
          {'type': 'Cramps', 'severity': 'moderate'},
        ],
        hydration: 'Good',
        mood: 'Calm',
      );

      expect(mockClient.lastEndpoint, '/symptoms/check-in');
      expect(result.id, 'symptom-001');
      expect(result.flow, 'medium');
      expect(result.symptoms.first.type, 'Cramps');
      expect(result.safetyAssessment?.isEmergency, isFalse);
    });

    test('getHistory parses array of logs', () async {
      mockClient.mockResponse = {
        'success': true,
        'data': {
          'logs': [
            {'date': '2026-10-24', 'flow': 'none', 'symptoms': []},
            {
              'date': '2026-10-25',
              'flow': 'medium',
              'symptoms': [
                {'type': 'Headache', 'severity': 'mild'},
              ],
            },
          ],
        },
      };

      final history = await service.getHistory(token: 'test-jwt');
      expect(history.length, 2);
      expect(history.first.date, '2026-10-24');
      expect(history.last.symptoms.first.type, 'Headache');
    });

    test('getLatest returns null when no logs exist', () async {
      mockClient.mockResponse = {'success': true, 'data': null};
      final latest = await service.getLatest('test-jwt');
      expect(latest, isNull);
    });
  });

  group('SafetyApiService Tests', () {
    late _MockApiClient mockClient;
    late SafetyApiService service;

    setUp(() {
      mockClient = _MockApiClient();
      service = SafetyApiService(client: mockClient);
    });

    test('evaluateTriage parses EMERGENCY_RED_FLAG triage response', () async {
      mockClient.mockResponse = {
        'success': true,
        'data': {
          'isRedFlag': true,
          'triageLevel': 'EMERGENCY_RED_FLAG',
          'alertHeadline': 'Immediate Emergency Evaluation Required',
          'explanation': 'Soaking two or more pads per hour for consecutive hours indicates acute hemorrhage.',
          'actionRequired':
              'Seek immediate emergency medical care or call 911.',
          'emergencyHelpline': '911 (US/Canada) or local emergency services',
          'recommendedSteps': [
            'Call emergency services immediately',
            'Do not drive yourself',
          ],
          'disclaimer': 'This evaluation is deterministic safety triage.',
        },
      };

      final result = await service.evaluateTriage(
        acuteSymptoms: ['soaking_two_pads_an_hour'],
        bleedingRate: 'soaking_two_pads_an_hour',
      );

      expect(result.isRedFlag, isTrue);
      expect(result.triageLevel, 'EMERGENCY_RED_FLAG');
      expect(result.emergencyHelpline, contains('911'));
      expect(result.recommendedSteps.length, 2);
    });

    test('evaluateTriage omits unspecified painScale and temperature to avoid assuming normal defaults', () async {
      mockClient.mockResponse = {
        'success': true,
        'data': {
          'isRedFlag': false,
          'triageLevel': 'ROUTINE',
          'alertHeadline': 'NO ACUTE RED FLAGS DETECTED',
          'explanation': 'Routine monitoring.',
          'actionRequired': 'Continue logging.',
          'emergencyHelpline': '112 / 911',
          'recommendedSteps': [],
          'disclaimer': 'Clinical disclaimer.',
        },
      };

      await service.evaluateTriage(acuteSymptoms: ['mild_headache']);

      expect(mockClient.lastBody, isNotNull);
      expect(mockClient.lastBody!.containsKey('painScale'), isFalse);
      expect(mockClient.lastBody!.containsKey('feverTemperatureC'), isFalse);
      expect(mockClient.lastBody!.containsKey('bleedingRate'), isFalse);
      expect(mockClient.lastBody!['acuteSymptoms'], equals(['mild_headache']));
    });
  });

  group('EmergencyConfig Tests', () {
    test('provides verified configurations for target launch countries', () {
      final us = EmergencyConfig.getByCode('US_CA');
      expect(us.emergencyNumber, '911');
      expect(us.crisisNumber, '988');
      expect(us.isVerified, isTrue);

      final india = EmergencyConfig.getByCode('IN');
      expect(india.emergencyNumber, '112');
      expect(india.crisisNumber, '14416');
      expect(india.crisisDescription, contains('Tele-MANAS'));
      expect(india.isVerified, isTrue);

      final uk = EmergencyConfig.getByCode('UK');
      expect(uk.emergencyNumber, '999');
      expect(uk.isVerified, isTrue);
    });
  });

  group('SessionStorage Tests', () {
    test(
      'InMemorySessionStorage stores, retrieves, and clears token and user',
      () async {
        final storage = InMemorySessionStorage();
        expect(await storage.getToken(), isNull);
        expect(await storage.getUser(), isNull);

        await storage.saveToken('jwt-token-xyz');
        expect(await storage.getToken(), 'jwt-token-xyz');

        final user = const UserModel(
          userId: 'u1',
          email: 'test@example.com',
          name: 'Test User',
        );
        await storage.saveUser(user);

        final retrievedUser = await storage.getUser();
        expect(retrievedUser?.email, 'test@example.com');
        expect(retrievedUser?.name, 'Test User');

        await storage.clearAll();
        expect(await storage.getToken(), isNull);
        expect(await storage.getUser(), isNull);
      },
    );
  });
}
