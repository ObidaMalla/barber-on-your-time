import '../../models/booking/createBooking/create_booking_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class CreateBookingRepository {
  final BookingService bookingService;
  CreateBookingRepository(this.bookingService);

  Future<CreateBookingModel> createBooking({
    required int serviceId,
    required int staffId,
    required String startTime,
  }) {
    return ApiExceptionHandler.handle<CreateBookingModel>(
      () => bookingService.createBooking({
        'serviceId': serviceId,
        'staffId': staffId,
        'startTime': startTime,
      }),
      fallbackErrorMessage: 'فشل إرسال طلب الحجز 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
