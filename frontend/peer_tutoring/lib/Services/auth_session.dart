import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peer_tutoring/models/user.dart';

class AuthSession {
  static const String _userKey = 'logged_in_user';

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);

    if (userData == null) return null;

    try {
      final json = jsonDecode(userData) as Map<String, dynamic>;
      return User.fromJson(json);
    } catch (_) {
      await clearSession();
      return null;
    }
  }

  static Future<int?> getUserId() async {
    final user = await getUser();
    return user?.id;
  }

  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user?.id != null;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static const String _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
