import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availability/requestAvailability/request_availability_model.dart';
import '../../repo/response_availability/request_availability_repo.dart';
import '../results_state.dart';

class RequestAvailabilityCubit
    extends Cubit<ResultState<RequestAvailabilityModel>> {
  final RequestAvailabilityRepo requestAvailabilityRepo;
  RequestAvailabilityCubit(this.requestAvailabilityRepo)
    : super(const ResultState.idle());

  Future<void> requestChange({
    required int availabilityId,
    required String date, // 👈 بدل dayOfWeek
    required String startTime,
    required String endTime,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await requestAvailabilityRepo.requestChange(
        RequestAvailabilityRequest(
          availabilityId: availabilityId,
          date: date, // 👈
          startTime: startTime,
          endTime: endTime,
        ),
      );
      debugPrint('✅ [RequestAvailabilityCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [RequestAvailabilityCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
