import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/profile/profile_model.dart';
import '../../repo/response_profile/profile_repo.dart';
import '../results_state.dart';

class ProfileCubit extends Cubit<ResultState<ProfileModel>> {
  final ProfileRepository profileRepo;
  ProfileCubit(this.profileRepo) : super(const ResultState.idle());

  Future<void> fetchProfile() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await profileRepo.getProfile();

      debugPrint('✅ [ProfileCubit] Fetch Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [ProfileCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
