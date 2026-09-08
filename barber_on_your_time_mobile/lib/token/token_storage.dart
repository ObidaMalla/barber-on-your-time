import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // --- حفظ واسترجاع حالة طلب التنبيه للحجز ---
  static Future<void> saveCompletionRequested(int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('requested_completion_$bookingId', true);
  }

  static Future<bool> isCompletionRequested(int bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('requested_completion_$bookingId') ?? false;
  }
}
