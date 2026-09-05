import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availability/getAvailability/get_availability_model.dart';
import '../../repo/response_availability/get_availability_repo.dart';
import '../results_state.dart';

class GetAvailabilityCubit extends Cubit<ResultState<GetAvailabilityModel>> {
  final GetAvailabilityRepo getAvailabilityRepo;
  GetAvailabilityCubit(this.getAvailabilityRepo)
    : super(const ResultState.idle());

  Future<void> fetchAvailability() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await getAvailabilityRepo.getMyAvailability();
      debugPrint('✅ [GetAvailabilityCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetAvailabilityCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
