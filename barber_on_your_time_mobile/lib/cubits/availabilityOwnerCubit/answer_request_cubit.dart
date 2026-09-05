import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availabilityOwner/answer_request_model.dart';
import '../../repo/response_availability_owner/owner_requests_repo.dart';
import '../results_state.dart';

class AnswerRequestCubit extends Cubit<ResultState<AnswerRequestModel>> {
  final OwnerRequestsRepo ownerRequestsRepo;
  AnswerRequestCubit(this.ownerRequestsRepo) : super(const ResultState.idle());

  Future<void> answerRequest({
    required int requestId,
    required String decision,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await ownerRequestsRepo.answerRequest(
        requestId: requestId,
        decision: decision,
      );
      debugPrint('✅ [AnswerRequestCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [AnswerRequestCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
