import '../../models/booking/getStaffBookings/get_staff_bookings_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class GetStaffBookingsRepository {
  final BookingService bookingService;
  GetStaffBookingsRepository(this.bookingService);

  Future<GetStaffBookingsModel> getStaffBookings() {
    return ApiExceptionHandler.handle<GetStaffBookingsModel>(
      () => bookingService.getStaffBookings(),
      fallbackErrorMessage: 'فشل جلب حجوزاتك 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
