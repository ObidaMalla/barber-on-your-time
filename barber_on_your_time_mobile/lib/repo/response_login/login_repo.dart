import '../../models/login/login_model.dart';
import '../../routes/auth/auth_routes.dart';
import '../apiExceptionHandler.dart';

class LoginRepository {
  final AuthService loginService;
  LoginRepository(this.loginService);

  Future<LoginModel> loginUser({
    required String email,
    required String password,
    String? fcmToken, // 👈 إمكانية استلام fcmToken
  }) {
    return ApiExceptionHandler.handle<LoginModel>(
      () => loginService.login({
        'email': email,
        'password': password,
        if (fcmToken != null) 'fcmToken': fcmToken, // 👈 يرسل فقط إن وجد
      }),
      fallbackErrorMessage: 'فشلت عملية تسجيل الدخول 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
