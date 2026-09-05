import '../../models/availability/requestAvailability/get_pending_requests_model.dart';
import '../../routes/availability/availability_service.dart';
import '../apiExceptionHandler.dart';

class GetPendingRequestsRepo {
  final AvailabilityService availabilityService;
  GetPendingRequestsRepo(this.availabilityService);

  Future<GetPendingRequestsModel> fetchPendingRequests() {
    return ApiExceptionHandler.handle<GetPendingRequestsModel>(
      () => availabilityService.getMyPendingRequests(),
      fallbackErrorMessage: 'فشل جلب الطلبات المعلقة 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
