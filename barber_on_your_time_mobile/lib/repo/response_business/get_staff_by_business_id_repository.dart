import '../../models/business/get_staff_by_business_id_model.dart';
import '../../routes/business_routes/business.dart';
import '../apiExceptionHandler.dart';

class GetStaffByBusinessIdRepository {
  final BusinessService businessService;

  GetStaffByBusinessIdRepository(this.businessService);

  Future<GetStaffByBusinessIdModel> getStaffByBusinessId(int businessId) {
    return ApiExceptionHandler.handle<GetStaffByBusinessIdModel>(
      () => businessService.getStaffByBusinessId(businessId),
      fallbackErrorMessage: 'فشل جلب قائمة موظفي المحل 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
