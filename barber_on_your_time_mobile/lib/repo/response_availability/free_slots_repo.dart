import '../../models/availability/free_slots/free_slots_model.dart';
import '../../routes/Availability/availability_service.dart';
import '../apiExceptionHandler.dart';

class FreeSlotsRepository {
  final AvailabilityService availabilityService;
  FreeSlotsRepository(this.availabilityService);

  Future<FreeSlotsModel> getFreeSlots() {
    return ApiExceptionHandler.handle<FreeSlotsModel>(
      () => availabilityService.getMyFreeSlots(),
      fallbackErrorMessage: 'فشل جلب أوقات الفراغ 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<FreeSlotsModel> getStaffFreeSlots(int staffId) {
    // 👈 جديد
    return ApiExceptionHandler.handle<FreeSlotsModel>(
      () => availabilityService.getStaffFreeSlots(staffId),
      fallbackErrorMessage: 'فشل جلب أوقات فراغ الحلاق 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
