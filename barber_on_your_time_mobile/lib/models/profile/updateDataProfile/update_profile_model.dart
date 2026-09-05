import 'package:json_annotation/json_annotation.dart';

part 'update_profile_model.g.dart';

@JsonSerializable()
class UpdateProfileModel {
  bool? success;
  int? statusCode;
  String? message;
  UpdateProfileData? data;

  UpdateProfileModel({this.success, this.statusCode, this.message, this.data});

  factory UpdateProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileModelToJson(this);
}

@JsonSerializable()
class UpdateProfileData {
  int? id;
  String? name;
  String? email;
  String? role;

  UpdateProfileData({this.id, this.name, this.email, this.role});

  factory UpdateProfileData.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileDataFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileDataToJson(this);
}
