import 'dart:convert';
import 'dart:io';

import '../../data/models/user_model.dart';
import 'session_storage.dart';

SessionStorage getPlatformSessionStorage() => IoSessionStorage();

/// Persists session token and user profile to an isolated local file cache.
class IoSessionStorage implements SessionStorage {
  File get _file =>
      File('${Directory.systemTemp.path}/inhercue_session_cache.json');

  Map<String, dynamic> _readData() {
    try {
      if (_file.existsSync()) {
        final content = _file.readAsStringSync();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {};
  }

  void _writeData(Map<String, dynamic> data) {
    try {
      _file.writeAsStringSync(jsonEncode(data));
    } catch (_) {}
  }

  @override
  Future<void> saveToken(String token) async {
    final data = _readData();
    data['token'] = token;
    _writeData(data);
  }

  @override
  Future<String?> getToken() async {
    final data = _readData();
    return data['token'] as String?;
  }

  @override
  Future<void> clearToken() async {
    final data = _readData();
    data.remove('token');
    _writeData(data);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final data = _readData();
    data['user'] = user.toJson();
    _writeData(data);
  }

  @override
  Future<UserModel?> getUser() async {
    final data = _readData();
    final userMap = data['user'];
    if (userMap is Map<String, dynamic>) {
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    final data = _readData();
    data.remove('user');
    _writeData(data);
  }

  @override
  Future<void> clearAll() async {
    try {
      if (_file.existsSync()) {
        _file.deleteSync();
      }
    } catch (_) {}
  }
}
