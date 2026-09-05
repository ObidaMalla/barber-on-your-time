import '../../models/availability/requestAvailability/request_availability_model.dart';
import '../../routes/availability/availability_service.dart';
import '../apiExceptionHandler.dart';

class RequestAvailabilityRepo {
  final AvailabilityService availabilityService;
  RequestAvailabilityRepo(this.availabilityService);

  Future<RequestAvailabilityModel> requestChange({
    required int availabilityId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
  }) {
    return ApiExceptionHandler.handle<RequestAvailabilityModel>(
      () => availabilityService.requestAvailabilityChange(
        RequestAvailabilityRequest(
          availabilityId: availabilityId,
          dayOfWeek: dayOfWeek,
          startTime: startTime,
          endTime: endTime,
        ),
      ),
      fallbackErrorMessage: 'فشل إرسال طلب التعديل 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
