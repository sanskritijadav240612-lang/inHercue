import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

/// Service for communicating with the inHercue authentication endpoints:
/// - POST /api/v1/auth/register
/// - POST /api/v1/auth/login
/// - GET /api/v1/auth/me
class AuthApiService {
  final ApiClient _client;

  AuthApiService({ApiClient? client}) : _client = client ?? ApiClient();

  /// Registers a new user.
  /// Requires name (2-60 chars), valid email, and password (>=8 chars with number & special char).
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
    int? age,
  }) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim().toLowerCase(),
      'password': password,
    };
    if (age != null) {
      body['age'] = age;
    }

    final response = await _client.post(ApiConfig.registerEndpoint, body: body);

    return AuthResponseModel.fromJson(response);
  }

  /// Logs in an existing user with email and password.
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final body = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
    };

    final response = await _client.post(ApiConfig.loginEndpoint, body: body);

    return AuthResponseModel.fromJson(response);
  }

  /// Retrieves the current authenticated user's profile using their JWT token.
  Future<UserModel> getMe(String token) async {
    final response = await _client.get(ApiConfig.meEndpoint, token: token);

    final data = response['data'] as Map<String, dynamic>? ?? {};
    return UserModel.fromJson(data);
  }
}
