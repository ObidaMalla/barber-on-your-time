import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/booking/ownerStaffStats/owner_staff_stats_model.dart';
import '../../repo/response_booking/owner_staff_stats_repo.dart';
import '../results_state.dart';

class OwnerStaffStatsCubit extends Cubit<ResultState<OwnerStaffStatsModel>> {
  final OwnerStaffStatsRepository ownerStaffStatsRepo;

  OwnerStaffStatsCubit(this.ownerStaffStatsRepo)
    : super(const ResultState.idle());

  Future<void> getStaffStatisticsForOwner(int staffId) async {
    if (isClosed) return;
    emit(const ResultState.loading());

    try {
      final response = await ownerStaffStatsRepo.getStaffStatisticsForOwner(
        staffId,
      );

      // 👈 التحقق من أن الكيوبيت ما زال يعمل قبل إرسال النتيجة
      if (!isClosed) {
        emit(ResultState.success(response));
      }
    } catch (error) {
      // 👈 التحقق أيضاً في حالة الخطأ
      if (!isClosed) {
        emit(ResultState.error(error is String ? error : error.toString()));
      }
    }
  }
}
