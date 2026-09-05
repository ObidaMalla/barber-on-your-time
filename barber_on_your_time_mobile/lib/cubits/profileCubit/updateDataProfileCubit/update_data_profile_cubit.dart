import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/profile/updateDataProfile/update_profile_model.dart';
import '../../../repo/response_profile/profile_repo.dart';
import '../../results_state.dart';

class UpdateProfileCubit extends Cubit<ResultState<UpdateProfileModel>> {
  final ProfileRepository profileRepo;
  UpdateProfileCubit(this.profileRepo) : super(const ResultState.idle());

  Future<void> updateProfile({String? name, String? email}) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await profileRepo.updateProfile(
        name: name,
        email: email,
      );
      debugPrint('✅ [UpdateProfileCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [UpdateProfileCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
