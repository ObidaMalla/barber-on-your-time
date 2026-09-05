import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/business/get_all_businesses_model.dart';
import '../../repo/response_business/get_all_businesses_repo.dart';
import '../results_state.dart';

class GetAllBusinessesCubit extends Cubit<ResultState<GetAllBusinessesModel>> {
  final GetAllBusinessesRepository getAllBusinessesRepo;

  GetAllBusinessesCubit(this.getAllBusinessesRepo)
    : super(const ResultState.idle());

  Future<void> getAllBusinesses() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await getAllBusinessesRepo.getAllBusinesses();

      debugPrint('✅ [GetAllBusinessesCubit] Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetAllBusinessesCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
