import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availability/requestDeletion/request_deletion_model.dart';
import '../../repo/response_availability/request_deletion_repo.dart';
import '../results_state.dart';

class RequestDeletionCubit extends Cubit<ResultState<RequestDeletionModel>> {
  final RequestDeletionRepo requestDeletionRepo;
  RequestDeletionCubit(this.requestDeletionRepo) : super(const ResultState.idle());

  Future<void> requestDeletion({required int availabilityId}) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await requestDeletionRepo.requestDeletion(
        availabilityId: availabilityId,
      );
      debugPrint('✅ [RequestDeletionCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [RequestDeletionCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}