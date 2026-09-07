import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availability/free_slots/free_slots_model.dart';
import '../../repo/response_availability/free_slots_repo.dart';
import '../results_state.dart';

class StaffFreeSlotsCubit extends Cubit<ResultState<FreeSlotsModel>> {
  final FreeSlotsRepository freeSlotsRepo;
  StaffFreeSlotsCubit(this.freeSlotsRepo) : super(const ResultState.idle());

  Future<void> getStaffFreeSlots(int staffId) async {
    emit(const ResultState.loading());
    try {
      final response = await freeSlotsRepo.getStaffFreeSlots(staffId);
      emit(ResultState.success(response));
    } catch (error) {
      emit(ResultState.error(error is String ? error : error.toString()));
    }
  }

  void resetState() {
    emit(const ResultState.idle());
  }
}
