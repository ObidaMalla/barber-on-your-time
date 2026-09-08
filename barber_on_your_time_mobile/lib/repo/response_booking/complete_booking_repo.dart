import '../../models/booking/completeBooking/complete_booking_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class CompleteBookingRepository {
  final BookingService bookingService;
  CompleteBookingRepository(this.bookingService);

  Future<CompleteBookingModel> completeBooking({
    required int bookingId,
    required String code,
  }) {
    return ApiExceptionHandler.handle<CompleteBookingModel>(
      () => bookingService.completeBooking(bookingId, {'code': code}),
      fallbackErrorMessage: 'فشل تأكيد اكتمال الخدمة 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
