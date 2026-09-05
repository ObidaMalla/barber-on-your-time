import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/availability/addAvailability/add_availability_model.dart';
import '../../models/availability/getAvailability/get_availability_model.dart';
import '../../models/availability/requestAvailability/get_pending_requests_model.dart';
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

  @GET('/availability/requests/mine')
  Future<GetPendingRequestsModel> getMyPendingRequests();

  // ===== جديد =====
  @POST('/availability/requests/delete')
  Future<RequestDeletionModel> requestAvailabilityDeletion(
    @Body() RequestDeletionRequest request,
  );
}
