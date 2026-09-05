import 'package:json_annotation/json_annotation.dart';

part 'register_model.g.dart';

@JsonSerializable()
class RegisterModel {
  bool? success;
  int? statusCode;
  String? message;
  DataRegister? data;

  RegisterModel({this.success, this.statusCode, this.message, this.data});

  factory RegisterModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterModelFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterModelToJson(this);
}

@JsonSerializable()
class DataRegister {
  int? id;
  String? name;
  String? email;
  String? role;
  String? createdAt;

  DataRegister({this.id, this.name, this.email, this.role, this.createdAt});

  factory DataRegister.fromJson(Map<String, dynamic> json) =>
      _$DataRegisterFromJson(json);
  Map<String, dynamic> toJson() => _$DataRegisterToJson(this);
}
