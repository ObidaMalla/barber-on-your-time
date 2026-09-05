import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/createBooking/create_booking_model.dart';
import '../../repo/response_booking/create_booking_repo.dart';
import '../results_state.dart';

class CreateBookingCubit extends Cubit<ResultState<CreateBookingModel>> {
  final CreateBookingRepository createBookingRepo;
  CreateBookingCubit(this.createBookingRepo) : super(const ResultState.idle());

  Future<void> createBooking({
    required int serviceId,
    required int staffId,
    required String startTime,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await createBookingRepo.createBooking(
        serviceId: serviceId,
        staffId: staffId,
        startTime: startTime,
      );
      debugPrint('✅ [CreateBookingCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [CreateBookingCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
