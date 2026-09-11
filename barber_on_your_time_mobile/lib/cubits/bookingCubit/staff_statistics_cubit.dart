import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/StaffStatistics/staff_statistics_model.dart';
import '../../repo/response_booking/staff_statistics_repo.dart';
import '../results_state.dart';

class StaffStatisticsCubit extends Cubit<ResultState<StaffStatisticsModel>> {
  final StaffStatisticsRepository statsRepo;
  StaffStatisticsCubit(this.statsRepo) : super(const ResultState.idle());

  Future<void> getMyStats() async {
    emit(const ResultState.loading());
    try {
      final response = await statsRepo.getStaffStatistics();
      emit(ResultState.success(response));
    } catch (error) {
      emit(ResultState.error(error is String ? error : error.toString()));
    }
  }
}
