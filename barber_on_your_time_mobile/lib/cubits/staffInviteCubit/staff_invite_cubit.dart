import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/staffInvite/staff_invite_model.dart';
import '../../repo/response_business/business_repo.dart';
import '../results_state.dart';

class StaffInviteCubit extends Cubit<ResultState<StaffInviteModel>> {
  final BusinessRepository businessRepo;
  StaffInviteCubit(this.businessRepo) : super(const ResultState.idle());

  Future<void> generateInvite() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await businessRepo.generateStaffInvite();
      debugPrint('✅ [StaffInviteCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [StaffInviteCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
