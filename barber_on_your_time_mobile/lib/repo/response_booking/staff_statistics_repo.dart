import '../../models/booking/StaffStatistics/staff_statistics_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class StaffStatisticsRepository {
  final BookingService bookingService; // 👈 التعديل هنا: استخدام BookingService

  StaffStatisticsRepository(this.bookingService); // 👈 التعديل هنا

  Future<StaffStatisticsModel> getStaffStatistics() {
    return ApiExceptionHandler.handle<StaffStatisticsModel>(
      () => bookingService.getStaffStatistics(),
      fallbackErrorMessage: 'فشل جلب الإحصائيات 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
