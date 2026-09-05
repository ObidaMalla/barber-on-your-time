import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availabilityOwner/get_owner_pending_requests_model.dart';
import '../../repo/response_availability_owner/owner_requests_repo.dart';
import '../results_state.dart';

class OwnerPendingRequestsCubit
    extends Cubit<ResultState<GetOwnerPendingRequestsModel>> {
  final OwnerRequestsRepo ownerRequestsRepo;
  OwnerPendingRequestsCubit(this.ownerRequestsRepo)
    : super(const ResultState.idle());

  Future<void> fetchPendingRequests() async {
    emit(const ResultState.loading());
    try {
      final response = await ownerRequestsRepo.fetchPendingRequests();
      debugPrint(
        '✅ [OwnerPendingRequestsCubit] Success: ${response.data?.length} pending',
      );
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [OwnerPendingRequestsCubit] $message');
      emit(ResultState.error(message));
    }
  }
}
