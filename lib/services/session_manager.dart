import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class SessionManager {
  static const String _tokenKey = 'jobinja.auth.token';
  static const String _userKey = 'jobinja.auth.user';
  static const String _localAccountsKey = 'jobinja.local.accounts';

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
      if (decoded is Map<String, dynamic>) return User.fromJson(decoded);
      if (decoded is Map) return User.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      await clearSession();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _getLocalAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localAccountsKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (_) {
      await prefs.remove(_localAccountsKey);
    }
    return <Map<String, dynamic>>[];
  }

  Future<void> saveLocalAccount(User user, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final accounts = await _getLocalAccounts();
    accounts.removeWhere((account) => account['email']?.toString().toLowerCase() == user.email.toLowerCase());
    accounts.add({
      'user': user.toJson(),
      'password': password,
    });
    await prefs.setString(_localAccountsKey, jsonEncode(accounts));
  }

  Future<User?> findLocalAccount(String email, String password) async {
    final accounts = await _getLocalAccounts();
    for (final account in accounts) {
      final userMap = account['user'];
      final savedPassword = account['password']?.toString();
      if (userMap is Map && savedPassword == password) {
        final user = User.fromJson(Map<String, dynamic>.from(userMap));
        if (user.email.toLowerCase() == email.toLowerCase()) return user;
      }
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
