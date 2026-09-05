import 'package:json_annotation/json_annotation.dart';

part 'update_password_model.g.dart';

@JsonSerializable()
class UpdatePasswordModel {
  bool? success;
  int? statusCode;
  String? message;
  dynamic data;

  UpdatePasswordModel({this.success, this.statusCode, this.message, this.data});

  factory UpdatePasswordModel.fromJson(Map<String, dynamic> json) =>
      _$UpdatePasswordModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePasswordModelToJson(this);
}
