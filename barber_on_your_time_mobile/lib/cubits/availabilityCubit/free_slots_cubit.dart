import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/availability/free_slots/free_slots_model.dart';
import '../../repo/response_availability/free_slots_repo.dart';
import '../results_state.dart';

class FreeSlotsCubit extends Cubit<ResultState<FreeSlotsModel>> {
  final FreeSlotsRepository freeSlotsRepo;
  FreeSlotsCubit(this.freeSlotsRepo) : super(const ResultState.idle());

  Future<void> getFreeSlots() async {
    if (isClosed) return;
    emit(const ResultState.loading());

    try {
      final response = await freeSlotsRepo.getFreeSlots();
      if (isClosed) return; // فحص الحماية بعد انتهاء طلب الشبكة
      emit(ResultState.success(response));
    } catch (error) {
      if (isClosed) return; // فحص الحماية في حال حدوث الخطأ
      emit(ResultState.error(error is String ? error : error.toString()));
    }
  }

  void resetState() {
    if (isClosed) return;
    emit(const ResultState.idle());
  }
}
