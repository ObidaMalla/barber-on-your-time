import '../../models/booking/respondBooking/respond_booking_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class RespondBookingRepository {
  final BookingService bookingService;
  RespondBookingRepository(this.bookingService);

  Future<RespondBookingModel> respondToBooking({
    required int bookingId,
    required String decision, // "ACCEPT" أو "REJECT"
  }) {
    return ApiExceptionHandler.handle<RespondBookingModel>(
      () => bookingService.respondToBooking(bookingId, {'decision': decision}),
      fallbackErrorMessage: 'فشل إرسال الرد 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
