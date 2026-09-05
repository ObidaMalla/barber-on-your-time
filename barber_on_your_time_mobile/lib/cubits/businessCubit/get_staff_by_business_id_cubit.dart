import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/business/get_staff_by_business_id_model.dart';
import '../../repo/response_business/get_staff_by_business_id_repository.dart';
import '../results_state.dart';

class GetStaffByBusinessIdCubit
    extends Cubit<ResultState<GetStaffByBusinessIdModel>> {
  final GetStaffByBusinessIdRepository getStaffByBusinessIdRepo;

  GetStaffByBusinessIdCubit(this.getStaffByBusinessIdRepo)
    : super(const ResultState.idle());

  Future<void> getStaffByBusinessId(int businessId) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await getStaffByBusinessIdRepo.getStaffByBusinessId(
        businessId,
      );

      debugPrint('✅ [GetStaffByBusinessIdCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetStaffByBusinessIdCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
