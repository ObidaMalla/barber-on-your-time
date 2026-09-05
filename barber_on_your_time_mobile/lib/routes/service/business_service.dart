import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/business/get_services_by_business_model.dart';
import '../../models/services/add_services/add_service_model.dart';
import '../../models/services/deleteService/delete_service_model.dart';
import '../../models/services/getServices/get_services_model.dart';
import '../../models/services/updateService/update_service_model.dart';

part 'business_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ServiceBarberShop {
  factory ServiceBarberShop(Dio dio, {String baseUrl}) = _ServiceBarberShop;

  // 🔒 عرض خدمات محلي

  @GET('/services')
  Future<GetServicesModel> getServices();

  // 🔒 إضافة خدمة جديدة (Owner فقط)
  @POST('/services')
  Future<AddServiceModel> addService(@Body() AddServiceRequest request);

  @PATCH('/services/{serviceId}')
  Future<UpdateServiceModel> updateService(
    @Path('serviceId') int serviceId,
    @Body() UpdateServiceRequest request,
  );
  @DELETE('/services/{serviceId}')
  Future<DeleteServiceModel> deleteService(@Path('serviceId') int serviceId);

  @GET('/services/business/{businessId}')
  Future<GetServicesByBusinessModel> getServicesByBusinessId(
    @Path('businessId') int businessId,
  );
}
