import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availability/requestAvailability/get_pending_requests_model.dart';
import '../../repo/response_availability/get_pending_requests_repo.dart';
import '../results_state.dart';

class GetPendingRequestsCubit
    extends Cubit<ResultState<GetPendingRequestsModel>> {
  final GetPendingRequestsRepo pendingRequestsRepo;
  GetPendingRequestsCubit(this.pendingRequestsRepo)
    : super(const ResultState.idle());

  Future<void> fetchPendingRequests() async {
    emit(const ResultState.loading());
    try {
      final response = await pendingRequestsRepo.fetchPendingRequests();
      debugPrint(
        '✅ [GetPendingRequestsCubit] Success: ${response.data?.length} pending',
      );
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetPendingRequestsCubit] $message');
      emit(ResultState.error(message));
    }
  }
}
