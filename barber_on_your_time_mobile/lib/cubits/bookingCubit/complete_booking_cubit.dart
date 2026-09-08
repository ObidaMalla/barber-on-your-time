import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/completeBooking/complete_booking_model.dart';
import '../../repo/response_booking/complete_booking_repo.dart';
import '../results_state.dart';

class CompleteBookingCubit extends Cubit<ResultState<CompleteBookingModel>> {
  final CompleteBookingRepository completeBookingRepo;
  CompleteBookingCubit(this.completeBookingRepo)
    : super(const ResultState.idle());

  Future<void> completeBooking({
    required int bookingId,
    required String code,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await completeBookingRepo.completeBooking(
        bookingId: bookingId,
        code: code,
      );
      debugPrint('✅ [CompleteBookingCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [CompleteBookingCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
