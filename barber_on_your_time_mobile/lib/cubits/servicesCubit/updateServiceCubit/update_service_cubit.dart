import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/services/updateService/update_service_model.dart';
import '../../../repo/response_services/update_services_repo.dart';
import '../../results_state.dart';

class UpdateServiceCubit extends Cubit<ResultState<UpdateServiceModel>> {
  final UpdateServicesRepo updateServicesRepo;
  UpdateServiceCubit(this.updateServicesRepo) : super(const ResultState.idle());

  Future<void> updateService({
    required int serviceId,
    required String name,
    required int durationMinutes,
    required double price,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await updateServicesRepo.updateService(
        serviceId: serviceId,
        name: name,
        durationMinutes: durationMinutes,
        price: price,
      );
      debugPrint('✅ [UpdateServiceCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [UpdateServiceCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
