import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/register/register_model.dart';

part 'register.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class RegisterService {
  factory RegisterService(Dio dio, {String baseUrl}) = _RegisterService;

  @POST('/auth/register')
  Future<RegisterModel> register(@Body() Map<String, dynamic> body);
}
