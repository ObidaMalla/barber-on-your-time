import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/notificateionService/notificationService.dart'; // 👈 مسار ملف NotificationService لديك
import '../../models/login/login_model.dart';
import '../../repo/response_login/login_repo.dart';
import '../../token/token_storage.dart';
import '../results_state.dart';

class LoginCubit extends Cubit<ResultState<LoginModel>> {
  final LoginRepository loginRepo;
  LoginCubit(this.loginRepo) : super(const ResultState.idle());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      // 1️⃣ جلب FCM Token قبل نداء الـ API
      String? fcmToken;
      try {
        fcmToken = await NotificationService.getFcmToken();
      } catch (e) {
        debugPrint('⚠️ [LoginCubit] فشل جلب fcmToken: $e');
        // سنستمر بعملية الـ Login دون توقف إذا فشل جلب التوكن
      }

      // 2️⃣ تمرير fcmToken إلى الـ Repository
      final response = await loginRepo.loginUser(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );

      final token = response.data?.token;
      final role = response.data?.user?.role;
      if (token != null) await TokenStorage.saveToken(token);
      if (role != null) await TokenStorage.saveRole(role);

      debugPrint('✅ [LoginCubit] Login Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [LoginCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
