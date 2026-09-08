import '../../models/booking/requestCompletion/request_completion_model.dart';
import '../../routes/booking/booking_routes.dart';
import '../apiExceptionHandler.dart';

class RequestCompletionRepository {
  final BookingService bookingService;
  RequestCompletionRepository(this.bookingService);

  Future<RequestCompletionModel> requestCompletion({required int bookingId}) {
    return ApiExceptionHandler.handle<RequestCompletionModel>(
      () => bookingService.requestCompletion(bookingId),
      fallbackErrorMessage: 'فشل إرسال طلب استلام الخدمة 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
