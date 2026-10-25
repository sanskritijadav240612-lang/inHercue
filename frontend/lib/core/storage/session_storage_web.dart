// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:convert';
import 'dart:html' as html;

import '../../data/models/user_model.dart';
import 'session_storage.dart';

SessionStorage getPlatformSessionStorage() => WebSessionStorage();

/// Persists session token and user profile in browser localStorage for Web.
class WebSessionStorage implements SessionStorage {
  static const _tokenKey = 'inhercue_session_token';
  static const _userKey = 'inhercue_session_user';

  @override
  Future<void> saveToken(String token) async {
    html.window.localStorage[_tokenKey] = token;
  }

  @override
  Future<String?> getToken() async {
    return html.window.localStorage[_tokenKey];
  }

  @override
  Future<void> clearToken() async {
    html.window.localStorage.remove(_tokenKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    html.window.localStorage[_userKey] = jsonEncode(user.toJson());
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = html.window.localStorage[_userKey];
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          return UserModel.fromJson(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    html.window.localStorage.remove(_userKey);
  }

  @override
  Future<void> clearAll() async {
    html.window.localStorage.remove(_tokenKey);
    html.window.localStorage.remove(_userKey);
  }
}
