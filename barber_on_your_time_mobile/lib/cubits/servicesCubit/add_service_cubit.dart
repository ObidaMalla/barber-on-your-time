import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/services/add_services/add_service_model.dart';
import '../../repo/response_services/add_services_repo.dart';
import '../results_state.dart';

class AddServiceCubit extends Cubit<ResultState<AddServiceModel>> {
  final AddServiceRepository addServiceRepo;

  AddServiceCubit(this.addServiceRepo) : super(const ResultState.idle());

  Future<void> addService({
    required String name,
    required int durationMinutes,
    required int price,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final request = AddServiceRequest(
        name: name,
        durationMinutes: durationMinutes,
        price: price,
      );
      final response = await addServiceRepo.addService(request);

      debugPrint('✅ [AddServiceCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [AddServiceCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
