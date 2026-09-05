import '../../models/services/getServices/get_services_model.dart';
import '../../routes/service/business_service.dart';
import '../apiExceptionHandler.dart';

class GetServicesRepository {
  final ServiceBarberShop serviceBarberShop;

  GetServicesRepository(this.serviceBarberShop);

  Future<GetServicesModel> getServices() {
    return ApiExceptionHandler.handle<GetServicesModel>(
      () => serviceBarberShop.getServices(),
      fallbackErrorMessage: 'فشل جلب قائمة الخدمات 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
