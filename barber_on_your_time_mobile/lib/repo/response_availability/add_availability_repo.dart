import '../../models/availability/addAvailability/add_availability_model.dart';
import '../../routes/availability/availability_service.dart';
import '../apiExceptionHandler.dart';

class AddAvailabilityRepo {
  final AvailabilityService availabilityService;
  AddAvailabilityRepo(this.availabilityService);

  Future<AddAvailabilityModel> addAvailability(AddAvailabilityRequest request) {
    return ApiExceptionHandler.handle<AddAvailabilityModel>(
      () => availabilityService.addAvailability(request),
      fallbackErrorMessage: 'فشل تحديد وقت الدوام 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
