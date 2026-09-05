import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/respondBooking/respond_booking_model.dart';
import '../../repo/response_booking/respond_booking_repo.dart';
import '../results_state.dart';

class RespondBookingCubit extends Cubit<ResultState<RespondBookingModel>> {
  final RespondBookingRepository respondBookingRepo;
  RespondBookingCubit(this.respondBookingRepo)
    : super(const ResultState.idle());

  Future<void> respondToBooking({
    required int bookingId,
    required String decision,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await respondBookingRepo.respondToBooking(
        bookingId: bookingId,
        decision: decision,
      );
      debugPrint('✅ [RespondBookingCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [RespondBookingCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
