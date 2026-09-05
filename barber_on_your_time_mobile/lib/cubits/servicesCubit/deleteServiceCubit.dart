import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/services/deleteService/delete_service_model.dart';
import '../../repo/response_services/delete_service_repo.dart';
import '../results_state.dart';

class DeleteServiceCubit extends Cubit<ResultState<DeleteServiceModel>> {
  final DeleteServiceRepo deleteServiceRepo;
  DeleteServiceCubit(this.deleteServiceRepo) : super(const ResultState.idle());

  Future<void> deleteService({required int serviceId}) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await deleteServiceRepo.deleteService(
        serviceId: serviceId,
      );
      debugPrint('✅ [DeleteServiceCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [DeleteServiceCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
