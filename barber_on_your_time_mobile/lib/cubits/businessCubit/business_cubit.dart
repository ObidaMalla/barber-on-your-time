import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/CreateBusiness/business_model.dart';
import '../../repo/response_business/business_repo.dart';
import '../../token/token_storage.dart';
import '../results_state.dart';

class CreateBusinessCubit extends Cubit<ResultState<CreateBusinessModel>> {
  final BusinessRepository businessRepo;

  CreateBusinessCubit(this.businessRepo) : super(const ResultState.idle());

  Future<void> createBusiness({
    required String name,
    required String address,
  }) async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await businessRepo.createBusiness(
        name: name,
        address: address,
      );

      // ترقية الدور لـ OWNER محلياً بعد نجاح إنشاء المحل
      await TokenStorage.saveRole('OWNER');

      debugPrint('✅ [CreateBusinessCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [CreateBusinessCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
