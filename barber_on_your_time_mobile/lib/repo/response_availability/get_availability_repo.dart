import '../../models/availability/getAvailability/get_availability_model.dart';
import '../../routes/availability/availability_service.dart';
import '../apiExceptionHandler.dart';

class GetAvailabilityRepo {
  final AvailabilityService availabilityService;
  GetAvailabilityRepo(this.availabilityService);

  Future<GetAvailabilityModel> getMyAvailability() {
    return ApiExceptionHandler.handle<GetAvailabilityModel>(
      () => availabilityService.getMyAvailability(),
      fallbackErrorMessage: 'فشل جلب أوقات دوامك 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
