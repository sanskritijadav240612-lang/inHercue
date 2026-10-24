import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/data/models/auth_response_model.dart';
import 'package:frontend/data/models/user_model.dart';

void main() {
  group('UserModel JSON parsing', () {
    test('parses full user model correctly', () {
      final json = {
        'userId': '671a9101f82c4a001a111111',
        'email': 'sanskriti@example.com',
        'name': 'Sanskriti Sharma',
        'age': 22,
        'onboardingCompleted': true,
        'createdAt': '2026-10-24T12:00:00.000Z',
      };

      final user = UserModel.fromJson(json);

      expect(user.userId, equals('671a9101f82c4a001a111111'));
      expect(user.email, equals('sanskriti@example.com'));
      expect(user.name, equals('Sanskriti Sharma'));
      expect(user.age, equals(22));
      expect(user.onboardingCompleted, isTrue);
      expect(user.createdAt, isNotNull);
      expect(user.createdAt!.year, equals(2026));
    });

    test('handles null age and missing createdAt safely', () {
      final json = {
        'userId': '671a9101f82c4a001a111111',
        'email': 'test@example.com',
        'name': 'Test User',
      };

      final user = UserModel.fromJson(json);

      expect(user.age, isNull);
      expect(user.onboardingCompleted, isFalse);
      expect(user.createdAt, isNull);
    });

    test('toJson produces expected map', () {
      final user = UserModel(
        userId: '123',
        email: 'test@example.com',
        name: 'Test',
        age: 25,
        onboardingCompleted: true,
      );

      final json = user.toJson();
      expect(json['userId'], equals('123'));
      expect(json['email'], equals('test@example.com'));
      expect(json['name'], equals('Test'));
      expect(json['age'], equals(25));
      expect(json['onboardingCompleted'], isTrue);
    });
  });

  group('AuthResponseModel JSON parsing', () {
    test('parses backend login response envelope correctly', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'userId': '671a9101f82c4a001a111111',
          'email': 'sanskriti@example.com',
          'name': 'Sanskriti',
          'token': 'jwt_token_sample_123',
          'onboardingCompleted': false,
        }
      };

      final authResponse = AuthResponseModel.fromJson(json);

      expect(authResponse.message, equals('Login successful'));
      expect(authResponse.token, equals('jwt_token_sample_123'));
      expect(authResponse.user.email, equals('sanskriti@example.com'));
      expect(authResponse.user.name, equals('Sanskriti'));
    });
  });
}
