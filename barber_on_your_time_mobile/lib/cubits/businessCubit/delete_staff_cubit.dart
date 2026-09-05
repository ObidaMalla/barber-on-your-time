import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/deleteStaff/delete_staff_model.dart';
import '../../repo/response_business/delete_staff_repo.dart';
import '../results_state.dart';

class DeleteStaffCubit extends Cubit<ResultState<DeleteStaffModel>> {
  final DeleteStaffRepository deleteStaffRepo;

  DeleteStaffCubit(this.deleteStaffRepo) : super(const ResultState.idle());

  Future<void> deleteStaff(int staffId) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await deleteStaffRepo.deleteStaff(staffId);
      debugPrint('✅ [DeleteStaffCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [DeleteStaffCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
