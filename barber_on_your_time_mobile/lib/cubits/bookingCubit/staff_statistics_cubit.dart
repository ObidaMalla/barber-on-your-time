import 'package:barber_on_your_time/models/booking/staffStatistics/staff_statistics_model.dart';
import 'package:barber_on_your_time/repo/response_booking/staff_statistics_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
