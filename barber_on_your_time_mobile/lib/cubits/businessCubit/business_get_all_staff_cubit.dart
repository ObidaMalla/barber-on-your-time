import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/getAllStaff/get_staff_model.dart';
import '../../repo/response_business/business_all_staff_repo.dart';
import '../results_state.dart';

class GetStaffCubit extends Cubit<ResultState<GetStaffModel>> {
  final BusinessGetAllStaffRepository getStaffRepo;

  GetStaffCubit(this.getStaffRepo) : super(const ResultState.idle());

  Future<void> fetchStaff() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await getStaffRepo.getStaff();

      debugPrint('✅ [GetStaffCubit] Fetch Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetStaffCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
