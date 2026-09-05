import '../../models/getAllStaff/get_staff_model.dart';
import '../../routes/business_routes/business.dart';
import '../apiExceptionHandler.dart';

class BusinessGetAllStaffRepository {
  final BusinessService businessService;

  BusinessGetAllStaffRepository(this.businessService);

  Future<GetStaffModel> getStaff() {
    return ApiExceptionHandler.handle<GetStaffModel>(
      () => businessService.getStaff(),
      fallbackErrorMessage: 'فشلت عملية جلب الموظفين 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
