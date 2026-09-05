import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/cancelBooking/cancel_booking_model.dart';
import '../../repo/response_booking/cancel_booking_repo.dart';
import '../results_state.dart';

class CancelBookingCubit extends Cubit<ResultState<CancelBookingModel>> {
  final CancelBookingRepository cancelBookingRepo;
  CancelBookingCubit(this.cancelBookingRepo) : super(const ResultState.idle());

  Future<void> cancelBooking({required int bookingId}) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await cancelBookingRepo.cancelBooking(
        bookingId: bookingId,
      );
      debugPrint('✅ [CancelBookingCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [CancelBookingCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
