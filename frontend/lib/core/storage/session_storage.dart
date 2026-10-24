import '../../data/models/user_model.dart';

/// Abstract contract for storing authentication session credentials.
/// Enables swapping between in-memory ephemeral storage (development/tests)
/// and encrypted hardware storage (production).
abstract class SessionStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();

  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}

/// In-memory implementation of [SessionStorage].
/// Suitable for development sessions, web tabs, and automated tests.
/// Note: Data is cleared when the application process terminates.
class InMemorySessionStorage implements SessionStorage {
  String? _token;
  UserModel? _user;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async {
    return _token;
  }

  @override
  Future<void> clearToken() async {
    _token = null;
  }

  @override
  Future<void> saveUser(UserModel user) async {
    _user = user;
  }

  @override
  Future<UserModel?> getUser() async {
    return _user;
  }

  @override
  Future<void> clearUser() async {
    _user = null;
  }

  @override
  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
  }
}
