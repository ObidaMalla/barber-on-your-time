import '../../models/services/add_services/add_service_model.dart';
import '../../routes/service/business_service.dart';
import '../apiExceptionHandler.dart';

class AddServiceRepository {
  final ServiceBarberShop serviceBarberShop;

  AddServiceRepository(this.serviceBarberShop);

  Future<AddServiceModel> addService(AddServiceRequest request) {
    return ApiExceptionHandler.handle<AddServiceModel>(
      () => serviceBarberShop.addService(request),
      fallbackErrorMessage: 'فشل إضافة الخدمة 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
