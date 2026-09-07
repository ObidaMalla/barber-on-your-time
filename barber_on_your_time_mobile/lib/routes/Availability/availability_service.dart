import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/availability/addAvailability/add_availability_model.dart';
import '../../models/availability/free_slots/free_slots_model.dart';
import '../../models/availability/getAvailability/get_availability_model.dart';
import '../../models/availability/requestAvailability/request_availability_model.dart';
import '../../models/availability/requestDeletion/request_deletion_model.dart';

part 'availability_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class AvailabilityService {
  factory AvailabilityService(Dio dio, {String baseUrl}) = _AvailabilityService;

  @GET('/availability')
  Future<GetAvailabilityModel> getMyAvailability();

  @POST('/availability')
  Future<AddAvailabilityModel> addAvailability(
    @Body() AddAvailabilityRequest request,
  );

  @POST('/availability/requests')
  Future<RequestAvailabilityModel> requestAvailabilityChange(
    @Body() RequestAvailabilityRequest request,
  );

  // ===== جديد =====
  @POST('/availability/requests/delete')
  Future<RequestDeletionModel> requestAvailabilityDeletion(
    @Body() RequestDeletionRequest request,
  );

  @GET('/availability/me/free-slots')
  Future<FreeSlotsModel> getMyFreeSlots();

  @GET('/availability/staff/{staffId}/free-slots') // 👈 جديد
  Future<FreeSlotsModel> getStaffFreeSlots(@Path('staffId') int staffId);
}
