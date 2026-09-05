import '../../models/services/updateService/update_service_model.dart';
import '../../routes/service/business_service.dart';
import '../apiExceptionHandler.dart';

class UpdateServicesRepo {
  final ServiceBarberShop serviceBarberShop;

  UpdateServicesRepo(this.serviceBarberShop);
  Future<UpdateServiceModel> updateService({
    required int serviceId,
    required String name,
    required int durationMinutes,
    required double price,
  }) {
    return ApiExceptionHandler.handle<UpdateServiceModel>(
      () => serviceBarberShop.updateService(
        serviceId,
        UpdateServiceRequest(
          name: name,
          durationMinutes: durationMinutes,
          price: price,
        ),
      ),
      fallbackErrorMessage: 'فشل تحديث الخدمة 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
