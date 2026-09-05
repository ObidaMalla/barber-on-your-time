import 'package:json_annotation/json_annotation.dart';

part 'get_staff_by_business_id_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GetStaffByBusinessIdModel {
  bool? success;
  int? statusCode;
  String? message;
  List<StaffMemberData>? data;

  GetStaffByBusinessIdModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetStaffByBusinessIdModel.fromJson(Map<String, dynamic> json) =>
      _$GetStaffByBusinessIdModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetStaffByBusinessIdModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StaffMemberData {
  int? id;
  bool? active;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? createdAt;

  StaffUserProfile? user;

  StaffMemberData({this.id, this.active, this.createdAt, this.user});

  factory StaffMemberData.fromJson(Map<String, dynamic> json) =>
      _$StaffMemberDataFromJson(json);

  Map<String, dynamic> toJson() => _$StaffMemberDataToJson(this);

  static DateTime? _dateTimeFromJson(String? date) =>
      date != null ? DateTime.tryParse(date) : null;

  static String? _dateTimeToJson(DateTime? date) => date?.toIso8601String();
}

@JsonSerializable()
class StaffUserProfile {
  int? id;
  String? name;
  String? email;
  String? role;

  StaffUserProfile({this.id, this.name, this.email, this.role});

  factory StaffUserProfile.fromJson(Map<String, dynamic> json) =>
      _$StaffUserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$StaffUserProfileToJson(this);
}
