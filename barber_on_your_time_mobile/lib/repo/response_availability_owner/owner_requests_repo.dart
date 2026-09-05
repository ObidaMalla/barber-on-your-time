import '../../models/availabilityOwner/answer_request_model.dart';
import '../../models/availabilityOwner/get_owner_pending_requests_model.dart';
import '../../routes/availabilityOwner/owner_requests_service.dart';
import '../apiExceptionHandler.dart';

class OwnerRequestsRepo {
  final OwnerRequestsService ownerRequestsService;
  OwnerRequestsRepo(this.ownerRequestsService);

  Future<GetOwnerPendingRequestsModel> fetchPendingRequests() {
    return ApiExceptionHandler.handle<GetOwnerPendingRequestsModel>(
      () => ownerRequestsService.getPendingRequests(),
      fallbackErrorMessage: 'فشل جلب الطلبات المعلقة 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<AnswerRequestModel> answerRequest({
    required int requestId,
    required String decision,
  }) {
    return ApiExceptionHandler.handle<AnswerRequestModel>(
      () => ownerRequestsService.answerRequest(
        requestId,
        AnswerRequestBody(decision: decision),
      ),
      fallbackErrorMessage: 'فشل تسجيل الرد 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
