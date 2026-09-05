import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/availabilityOwner/answer_request_model.dart';
import '../../models/availabilityOwner/get_owner_pending_requests_model.dart';

part 'owner_requests_service.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class OwnerRequestsService {
  factory OwnerRequestsService(Dio dio, {String baseUrl}) =
      _OwnerRequestsService;

  @GET('/availability/requests')
  Future<GetOwnerPendingRequestsModel> getPendingRequests();

  @PATCH('/availability/requests/{requestId}')
  Future<AnswerRequestModel> answerRequest(
    @Path('requestId') int requestId,
    @Body() AnswerRequestBody body,
  );
}
