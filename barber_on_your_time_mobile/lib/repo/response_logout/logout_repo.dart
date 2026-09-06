import '../../models/logout/logout_model.dart';
import '../../routes/auth/auth_routes.dart';
import '../apiExceptionHandler.dart';

class LogoutRepository {
  final AuthService authService;
  LogoutRepository(this.authService);

  Future<LogoutModel> logoutUser() {
    return ApiExceptionHandler.handle<LogoutModel>(
      () => authService.logout(),
      fallbackErrorMessage: 'فشلت عملية تسجيل الخروج 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
