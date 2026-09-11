import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/ownerStaffStats/owner_staff_stats_model.dart';
import '../../repo/response_booking/owner_staff_stats_repo.dart';
import '../results_state.dart';

class OwnerStaffStatsCubit extends Cubit<ResultState<OwnerStaffStatsModel>> {
  final OwnerStaffStatsRepository ownerStaffStatsRepo;

  OwnerStaffStatsCubit(this.ownerStaffStatsRepo)
    : super(const ResultState.idle());

  Future<void> getStaffStatisticsForOwner(int staffId) async {
    emit(const ResultState.loading());
    try {
      final response = await ownerStaffStatsRepo.getStaffStatisticsForOwner(
        staffId,
      );
      emit(ResultState.success(response));
    } catch (error) {
      emit(ResultState.error(error is String ? error : error.toString()));
    }
  }
}
