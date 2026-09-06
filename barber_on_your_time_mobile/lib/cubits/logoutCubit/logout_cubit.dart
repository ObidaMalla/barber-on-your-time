import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/logout/logout_model.dart';
import '../../repo/response_logout/logout_repo.dart'; // 👈 عدّل المسار حسب مكان LogoutRepository عندك
import '../../token/token_storage.dart';
import '../results_state.dart';

class LogoutCubit extends Cubit<ResultState<LogoutModel>> {
  final LogoutRepository logoutRepo;
  LogoutCubit(this.logoutRepo) : super(const ResultState.idle());

  Future<void> logoutUser() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      // 1️⃣ نداء الـ API لتسجيل الخروج
      final response = await logoutRepo.logoutUser();

      // 2️⃣ مسح التوكن فقط — الـ role بيضل محفوظ عشان ما ينلخبط
      // (مو معقول اللي يعمل logout يرجع customer)
      await TokenStorage.removeToken();

      debugPrint('✅ [LogoutCubit] Logout Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [LogoutCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
