import '../../models/CreateBusiness/business_model.dart';
import '../../models/joinBusiness/join_business_model.dart';
import '../../models/staffInvite/staff_invite_model.dart';
import '../../routes/business_routes/business.dart';
import '../apiExceptionHandler.dart';

class BusinessRepository {
  final BusinessService businessService;

  BusinessRepository(this.businessService);

  Future<CreateBusinessModel> createBusiness({
    required String name,
    required String address,
  }) {
    return ApiExceptionHandler.handle<CreateBusinessModel>(
      () => businessService.createBusiness({'name': name, 'address': address}),
      fallbackErrorMessage: 'فشلت عملية إنشاء المحل 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<StaffInviteModel> generateStaffInvite() {
    return ApiExceptionHandler.handle<StaffInviteModel>(
      () => businessService.generateStaffInvite(),
      fallbackErrorMessage: 'فشل توليد الكود 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<JoinBusinessModel> joinBusiness({required String code}) {
    return ApiExceptionHandler.handle<JoinBusinessModel>(
      () => businessService.joinBusiness({'code': code}),
      fallbackErrorMessage: 'فشل الانضمام للمحل 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
