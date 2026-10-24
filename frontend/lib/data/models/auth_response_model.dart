import 'user_model.dart';

/// Encapsulates authentication responses from `/api/v1/auth/register` and `/api/v1/auth/login`.
class AuthResponseModel {
  final String token;
  final UserModel user;
  final String message;

  const AuthResponseModel({
    required this.token,
    required this.user,
    required this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final message = json['message'] as String? ?? 'Authentication successful';
    final data = json['data'] as Map<String, dynamic>? ?? {};

    final token = data['token'] as String? ?? '';
    final user = UserModel.fromJson(data);

    return AuthResponseModel(
      token: token,
      user: user,
      message: message,
    );
  }

  @override
  String toString() => 'AuthResponseModel(user: ${user.email}, hasToken: ${token.isNotEmpty})';
}
