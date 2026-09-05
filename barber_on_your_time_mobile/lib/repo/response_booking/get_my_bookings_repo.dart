import '../../models/booking/getMyBookings/get_my_bookings_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class GetMyBookingsRepository {
  final BookingService bookingService;
  GetMyBookingsRepository(this.bookingService);

  Future<GetMyBookingsModel> getMyBookings() {
    return ApiExceptionHandler.handle<GetMyBookingsModel>(
      () => bookingService.getMyBookings(),
      fallbackErrorMessage: 'فشل تحميل حجوزاتي 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
