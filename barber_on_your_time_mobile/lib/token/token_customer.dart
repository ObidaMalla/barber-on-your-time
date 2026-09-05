import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static Future<void> saveToken(String token) async {
    /// فتح مخزن البيانات
    final prefs = await SharedPreferences.getInstance();

    /// تخزين التوكين تحت اسم مستعار 'auth_token'
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    /// البحث عن القيمة المخزنة تحت اسم 'auth_token'
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
