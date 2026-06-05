import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class SessionManager {
  static const String _tokenKey = 'jobinja.auth.token';
  static const String _userKey = 'jobinja.auth.user';

  Future<void> saveSession(User user, {String? fallbackToken}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = user.token ?? fallbackToken;
    if (token != null && token.isNotEmpty) {
      await prefs.setString(_tokenKey, token);
    }
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token == null || token.isEmpty ? null : token;
  }

  Future<User?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_userKey);
    if (rawUser == null || rawUser.isEmpty) return null;
    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        return User.fromJson(decoded);
      }
      if (decoded is Map) {
        return User.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      await clearSession();
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getCachedUser();
    return token != null && user != null;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
