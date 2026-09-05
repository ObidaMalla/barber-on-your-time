import '../../models/business/get_all_businesses_model.dart';
import '../../routes/business_routes/business.dart';
import '../apiExceptionHandler.dart';

class GetAllBusinessesRepository {
  final BusinessService businessService;

  GetAllBusinessesRepository(this.businessService);

  Future<GetAllBusinessesModel> getAllBusinesses() {
    return ApiExceptionHandler.handle<GetAllBusinessesModel>(
      () => businessService.getAllBusinesses(),
      fallbackErrorMessage: 'فشل جلب قائمة المحلات 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
