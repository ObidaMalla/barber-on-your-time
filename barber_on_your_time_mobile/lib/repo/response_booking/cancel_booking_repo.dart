import '../../models/booking/cancelBooking/cancel_booking_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class CancelBookingRepository {
  final BookingService bookingService;
  CancelBookingRepository(this.bookingService);

  Future<CancelBookingModel> cancelBooking({required int bookingId}) {
    return ApiExceptionHandler.handle<CancelBookingModel>(
      () => bookingService.cancelBooking(bookingId),
      fallbackErrorMessage: 'فشل إلغاء الحجز 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
