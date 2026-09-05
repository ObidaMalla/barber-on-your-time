import '../../models/deleteStaff/delete_staff_model.dart';
import '../../routes/business_routes/business.dart';
import '../apiExceptionHandler.dart';

class DeleteStaffRepository {
  final BusinessService businessService;

  DeleteStaffRepository(this.businessService);

  Future<DeleteStaffModel> deleteStaff(int staffId) {
    return ApiExceptionHandler.handle<DeleteStaffModel>(
      () => businessService.deleteStaff(staffId),
      fallbackErrorMessage: 'فشلت عملية إزالة الموظف 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
