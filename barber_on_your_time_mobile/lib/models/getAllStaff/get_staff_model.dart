import 'package:json_annotation/json_annotation.dart';

part 'get_staff_model.g.dart';

@JsonSerializable()
class GetStaffModel {
  bool? success;
  int? statusCode;
  String? message;
  List<StaffData>? data;

  GetStaffModel({this.success, this.statusCode, this.message, this.data});

  factory GetStaffModel.fromJson(Map<String, dynamic> json) =>
      _$GetStaffModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetStaffModelToJson(this);
}

@JsonSerializable()
class StaffData {
  int? id;
  bool? active;
  String? createdAt;
  StaffUser? user;

  StaffData({this.id, this.active, this.createdAt, this.user});

  factory StaffData.fromJson(Map<String, dynamic> json) =>
      _$StaffDataFromJson(json);

  Map<String, dynamic> toJson() => _$StaffDataToJson(this);
}

@JsonSerializable()
class StaffUser {
  int? id;
  String? name;
  String? email;
  String? role;

  StaffUser({this.id, this.name, this.email, this.role});

  factory StaffUser.fromJson(Map<String, dynamic> json) =>
      _$StaffUserFromJson(json);

  Map<String, dynamic> toJson() => _$StaffUserToJson(this);
}
