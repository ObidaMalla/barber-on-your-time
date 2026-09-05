import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/services/getServices/get_services_model.dart';
import '../../repo/response_services/get_services_repo.dart';
import '../results_state.dart';

class GetServicesCubit extends Cubit<ResultState<GetServicesModel>> {
  final GetServicesRepository getServicesRepo;

  GetServicesCubit(this.getServicesRepo) : super(const ResultState.idle());

  Future<void> fetchServices() async {
    final isAlreadyLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );
    if (isAlreadyLoading) return;

    emit(const ResultState.loading());
    try {
      final response = await getServicesRepo.getServices();

      debugPrint('✅ [GetServicesCubit] Fetch Success: ${response.message}');
      emit(ResultState.success(response));
    } catch (error) {
      final String message = error is String ? error : error.toString();
      debugPrint('❌ [GetServicesCubit] $message');
      emit(ResultState.error(message));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
