import '../../models/availability/requestDeletion/request_deletion_model.dart';
import '../../routes/availability/availability_service.dart';
import '../apiExceptionHandler.dart';

class RequestDeletionRepo {
  final AvailabilityService availabilityService;
  RequestDeletionRepo(this.availabilityService);

  Future<RequestDeletionModel> requestDeletion({required int availabilityId}) {
    return ApiExceptionHandler.handle<RequestDeletionModel>(
      () => availabilityService.requestAvailabilityDeletion(
        RequestDeletionRequest(availabilityId: availabilityId),
      ),
      fallbackErrorMessage: 'فشل إرسال طلب الحذف 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
