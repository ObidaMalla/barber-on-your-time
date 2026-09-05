import '../../models/business/get_services_by_business_model.dart';
import '../../routes/service/business_service.dart';
import '../apiExceptionHandler.dart';

class GetServicesByBusinessRepository {
  final ServiceBarberShop serviceBarberShop;

  GetServicesByBusinessRepository(this.serviceBarberShop);

  Future<GetServicesByBusinessModel> getServicesByBusinessId(int businessId) {
    return ApiExceptionHandler.handle<GetServicesByBusinessModel>(
      () => serviceBarberShop.getServicesByBusinessId(businessId),
      fallbackErrorMessage: 'فشل جلب قائمة خدمات المحل 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
