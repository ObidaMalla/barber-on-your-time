import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/profile/updatePasswordProfile/update_password_model.dart';
import '../../../repo/response_profile/profile_repo.dart';
import '../../results_state.dart';

class UpdatePasswordCubit extends Cubit<ResultState<UpdatePasswordModel>> {
  final ProfileRepository profileRepo;
  UpdatePasswordCubit(this.profileRepo) : super(const ResultState.idle());

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await profileRepo.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      debugPrint('✅ [UpdatePasswordCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [UpdatePasswordCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
