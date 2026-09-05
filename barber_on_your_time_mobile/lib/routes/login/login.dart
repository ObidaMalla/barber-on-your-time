import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/login/login_model.dart';

part 'login.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class LoginService {
  factory LoginService(Dio dio, {String baseUrl}) = _LoginService;

  @POST('/auth/login')
  Future<LoginModel> login(@Body() Map<String, dynamic> body);
}
