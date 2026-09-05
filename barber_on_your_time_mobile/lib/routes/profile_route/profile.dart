import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/profile/profile_model.dart';
import '../../models/profile/updateDataProfile/update_profile_model.dart';
import '../../models/profile/updatePasswordProfile/update_password_model.dart';

part 'profile.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class ProfileService {
  factory ProfileService(Dio dio, {String baseUrl}) = _ProfileService;

  @GET('/users/me')
  Future<ProfileModel> getProfile();

  @PATCH('/users/me')
  Future<UpdateProfileModel> updateProfile(@Body() Map<String, dynamic> body);

  @PATCH('/users/me/password')
  Future<UpdatePasswordModel> updatePassword(@Body() Map<String, dynamic> body);
}
