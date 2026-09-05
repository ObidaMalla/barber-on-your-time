import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/register/register_model.dart';
import '../../repo/response_register/register_repo.dart';
import '../results_state.dart';

class RegisterCubit extends Cubit<ResultState<RegisterModel>> {
  final RegisterRepository registerRepo;
  RegisterCubit(this.registerRepo) : super(const ResultState.idle());

  Future<void> registerUser({
    required String name,
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
      final response = await registerRepo.registerUser(
        name: name,
        email: email,
        password: password,
      );

      debugPrint('✅ [RegisterCubit] Register Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [RegisterCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
