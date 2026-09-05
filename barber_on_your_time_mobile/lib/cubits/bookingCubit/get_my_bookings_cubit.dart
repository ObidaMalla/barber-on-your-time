import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/getMyBookings/get_my_bookings_model.dart';
import '../../repo/response_booking/get_my_bookings_repo.dart';
import '../results_state.dart';

class GetMyBookingsCubit extends Cubit<ResultState<GetMyBookingsModel>> {
  final GetMyBookingsRepository getMyBookingsRepo;
  GetMyBookingsCubit(this.getMyBookingsRepo) : super(const ResultState.idle());

  Future<void> getMyBookings() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await getMyBookingsRepo.getMyBookings();
      debugPrint('✅ [GetMyBookingsCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetMyBookingsCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
