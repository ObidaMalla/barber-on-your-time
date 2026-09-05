import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/business/get_services_by_business_model.dart';
import '../../repo/response_services/get_services_by_business_repository.dart';
import '../results_state.dart';

class GetServicesByBusinessCubit
    extends Cubit<ResultState<GetServicesByBusinessModel>> {
  final GetServicesByBusinessRepository getServicesByBusinessRepo;

  GetServicesByBusinessCubit(this.getServicesByBusinessRepo)
    : super(const ResultState.idle());

  Future<void> getServicesByBusinessId(int businessId) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await getServicesByBusinessRepo.getServicesByBusinessId(
        businessId,
      );

      debugPrint('✅ [GetServicesByBusinessCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetServicesByBusinessCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
