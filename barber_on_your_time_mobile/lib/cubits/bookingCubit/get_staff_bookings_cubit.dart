import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/getStaffBookings/get_staff_bookings_model.dart';
import '../../repo/response_booking/get_staff_bookings_repo.dart';
import '../results_state.dart';

class GetStaffBookingsCubit extends Cubit<ResultState<GetStaffBookingsModel>> {
  final GetStaffBookingsRepository getStaffBookingsRepo;
  GetStaffBookingsCubit(this.getStaffBookingsRepo)
    : super(const ResultState.idle());

  Future<void> fetchStaffBookings() async {
    emit(const ResultState.loading());
    try {
      final response = await getStaffBookingsRepo.getStaffBookings();
      debugPrint('✅ [GetStaffBookingsCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetStaffBookingsCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
