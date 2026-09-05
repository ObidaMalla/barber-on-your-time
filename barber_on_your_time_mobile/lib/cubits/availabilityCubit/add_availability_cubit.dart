import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availability/addAvailability/add_availability_model.dart';
import '../../repo/response_availability/add_availability_repo.dart';
import '../results_state.dart';

class AddAvailabilityCubit extends Cubit<ResultState<AddAvailabilityModel>> {
  final AddAvailabilityRepo addAvailabilityRepo;
  AddAvailabilityCubit(this.addAvailabilityRepo)
    : super(const ResultState.idle());

  Future<void> addAvailability({
    required int dayOfWeek,
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
      final request = AddAvailabilityRequest(
        dayOfWeek: dayOfWeek,
        startTime: startTime,
        endTime: endTime,
      );
      final response = await addAvailabilityRepo.addAvailability(request);
      debugPrint('✅ [AddAvailabilityCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [AddAvailabilityCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
