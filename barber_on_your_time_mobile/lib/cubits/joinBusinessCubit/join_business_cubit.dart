import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/joinBusiness/join_business_model.dart';
import '../../repo/response_business/business_repo.dart';
import '../results_state.dart';

class JoinBusinessCubit extends Cubit<ResultState<JoinBusinessModel>> {
  final BusinessRepository businessRepo;
  JoinBusinessCubit(this.businessRepo) : super(const ResultState.idle());

  Future<void> joinBusiness({required String code}) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await businessRepo.joinBusiness(code: code);
      debugPrint('✅ [JoinBusinessCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [JoinBusinessCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() => emit(const ResultState.idle());
}
