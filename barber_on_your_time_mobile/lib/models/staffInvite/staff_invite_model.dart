import 'package:json_annotation/json_annotation.dart';

part 'staff_invite_model.g.dart';

@JsonSerializable()
class StaffInviteModel {
  bool? success;
  int? statusCode;
  String? message;
  StaffInviteData? data;

  StaffInviteModel({this.success, this.statusCode, this.message, this.data});

  factory StaffInviteModel.fromJson(Map<String, dynamic> json) =>
      _$StaffInviteModelFromJson(json);
  Map<String, dynamic> toJson() => _$StaffInviteModelToJson(this);
}

@JsonSerializable()
class StaffInviteData {
  String? code;

  StaffInviteData({this.code});

  factory StaffInviteData.fromJson(Map<String, dynamic> json) =>
      _$StaffInviteDataFromJson(json);
  Map<String, dynamic> toJson() => _$StaffInviteDataToJson(this);
}
