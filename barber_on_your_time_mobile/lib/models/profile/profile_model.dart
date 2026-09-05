import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  bool? success;
  int? statusCode;
  String? message;
  ProfileData? data;

  ProfileModel({this.success, this.statusCode, this.message, this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}

@JsonSerializable()
class ProfileData {
  int? id;
  String? name;
  String? email;
  String? role;
  String? createdAt;

  ProfileData({this.id, this.name, this.email, this.role, this.createdAt});

  factory ProfileData.fromJson(Map<String, dynamic> json) =>
      _$ProfileDataFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileDataToJson(this);
}
