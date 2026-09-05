import 'package:json_annotation/json_annotation.dart';

part 'get_owner_pending_requests_model.g.dart';

// Response Model
@JsonSerializable()
class GetOwnerPendingRequestsModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final List<OwnerPendingRequestData>? data;

  GetOwnerPendingRequestsModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetOwnerPendingRequestsModel.fromJson(Map<String, dynamic> json) =>
      _$GetOwnerPendingRequestsModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetOwnerPendingRequestsModelToJson(this);
}

@JsonSerializable()
class OwnerPendingRequestData {
  final int? id;
  final String? type;
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? status;
  final int? staffId;
  final int? availabilityId;
  final String? createdAt;
  final RequestStaffInfo? staff;

  OwnerPendingRequestData({
    this.id,
    this.type,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.status,
    this.staffId,
    this.availabilityId,
    this.createdAt,
    this.staff,
  });

  factory OwnerPendingRequestData.fromJson(Map<String, dynamic> json) =>
      _$OwnerPendingRequestDataFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerPendingRequestDataToJson(this);
}

@JsonSerializable()
class RequestStaffInfo {
  final int? id;
  final int? userId;
  final RequestStaffUser? user;

  RequestStaffInfo({this.id, this.userId, this.user});

  factory RequestStaffInfo.fromJson(Map<String, dynamic> json) =>
      _$RequestStaffInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RequestStaffInfoToJson(this);
}

@JsonSerializable()
class RequestStaffUser {
  final int? id;
  final String? name;
  final String? email;

  RequestStaffUser({this.id, this.name, this.email});

  factory RequestStaffUser.fromJson(Map<String, dynamic> json) =>
      _$RequestStaffUserFromJson(json);

  Map<String, dynamic> toJson() => _$RequestStaffUserToJson(this);
}
