import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  bool? success;
  int? statusCode;
  String? message;
  LoginData? data;

  LoginModel({this.success, this.statusCode, this.message, this.data});

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}

@JsonSerializable()
class LoginData {
  String? token;
  LoginUser? user;

  LoginData({this.token, this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) =>
      _$LoginDataFromJson(json);
  Map<String, dynamic> toJson() => _$LoginDataToJson(this);
}

@JsonSerializable()
class LoginUser {
  int? id;
  String? name;
  String? email;
  String? role;

  LoginUser({this.id, this.name, this.email, this.role});

  factory LoginUser.fromJson(Map<String, dynamic> json) =>
      _$LoginUserFromJson(json);
  Map<String, dynamic> toJson() => _$LoginUserToJson(this);
}
