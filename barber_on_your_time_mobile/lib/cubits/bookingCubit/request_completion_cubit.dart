import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/requestCompletion/request_completion_model.dart';
import '../../repo/response_booking/request_completion_repo.dart';
import '../results_state.dart';

class RequestCompletionCubit
    extends Cubit<ResultState<RequestCompletionModel>> {
  final RequestCompletionRepository requestCompletionRepo;
  RequestCompletionCubit(this.requestCompletionRepo)
    : super(const ResultState.idle());

  Future<void> requestCompletion({required int bookingId}) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await requestCompletionRepo.requestCompletion(
        bookingId: bookingId,
      );
      debugPrint('✅ [RequestCompletionCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [RequestCompletionCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
