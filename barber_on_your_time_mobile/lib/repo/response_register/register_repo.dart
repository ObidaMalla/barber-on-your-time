import '../../models/register/register_model.dart';
import '../../routes/register/register.dart';
import '../apiExceptionHandler.dart';

class RegisterRepository {
  final RegisterService registerService;
  RegisterRepository(this.registerService);

  Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) {
    return ApiExceptionHandler.handle<RegisterModel>(
      () => registerService.register({
        'name': name,
        'email': email,
        'password': password,
      }),
      fallbackErrorMessage: 'فشلت عملية إنشاء الحساب 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
