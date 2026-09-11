import '../../models/booking/ownerStaffStats/owner_staff_stats_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class OwnerStaffStatsRepository {
  final BookingService bookingService;

  OwnerStaffStatsRepository(this.bookingService);

  Future<OwnerStaffStatsModel> getStaffStatisticsForOwner(int staffId) {
    return ApiExceptionHandler.handle<OwnerStaffStatsModel>(
      () => bookingService.getStaffStatisticsForOwner(staffId),
      fallbackErrorMessage: 'فشل جلب إحصائيات الحلاق 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
