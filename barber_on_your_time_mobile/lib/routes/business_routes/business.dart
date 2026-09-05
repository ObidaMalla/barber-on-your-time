import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/CreateBusiness/business_model.dart';
import '../../models/business/get_all_businesses_model.dart';
import '../../models/business/get_staff_by_business_id_model.dart';
import '../../models/deleteStaff/delete_staff_model.dart';
import '../../models/getAllStaff/get_staff_model.dart';
import '../../models/joinBusiness/join_business_model.dart';
import '../../models/staffInvite/staff_invite_model.dart';

part 'business.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class BusinessService {
  factory BusinessService(Dio dio, {String baseUrl}) = _BusinessService;

  // 🟢 1. جلب قائمة جميع المحلات المتاحة للزبائن
  @GET('/business')
  Future<GetAllBusinessesModel> getAllBusinesses();

  @GET('/business/{businessId}/staff')
  Future<GetStaffByBusinessIdModel> getStaffByBusinessId(
    @Path('businessId') int businessId,
  );

  @POST('/business')
  Future<CreateBusinessModel> createBusiness(@Body() Map<String, dynamic> body);

  @POST('/business/staff-invites')
  Future<StaffInviteModel> generateStaffInvite();

  @POST('/business/join')
  Future<JoinBusinessModel> joinBusiness(@Body() Map<String, dynamic> body);

  @GET('/business/staff')
  Future<GetStaffModel> getStaff();

  @DELETE('/business/staff/{staffId}')
  Future<DeleteStaffModel> deleteStaff(@Path('staffId') int staffId);
}
