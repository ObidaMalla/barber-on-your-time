import '../../models/services/deleteService/delete_service_model.dart';
import '../../routes/service/business_service.dart';
import '../apiExceptionHandler.dart';

class DeleteServiceRepo {
  final ServiceBarberShop serviceBarberShop;
  DeleteServiceRepo(this.serviceBarberShop);

  Future<DeleteServiceModel> deleteService({required int serviceId}) {
    return ApiExceptionHandler.handle<DeleteServiceModel>(
      () => serviceBarberShop.deleteService(serviceId),
      fallbackErrorMessage: 'فشل حذف الخدمة 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
