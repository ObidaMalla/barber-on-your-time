import 'package:json_annotation/json_annotation.dart';

part 'get_my_bookings_model.g.dart';

@JsonSerializable()
class GetMyBookingsModel {
  bool? success;
  int? statusCode;
  String? message;
  List<MyBookingData>? data;

  GetMyBookingsModel({this.success, this.statusCode, this.message, this.data});

  factory GetMyBookingsModel.fromJson(Map<String, dynamic> json) =>
      _$GetMyBookingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetMyBookingsModelToJson(this);
}

@JsonSerializable()
class MyBookingData {
  int? id;
  String? startTime;
  String? status;
  int? customerId;
  int? serviceId;
  int? staffId;
  String? createdAt;
  MyBookingService? service;
  MyBookingStaffInfo? staff;

  MyBookingData({
    this.id,
    this.startTime,
    this.status,
    this.customerId,
    this.serviceId,
    this.staffId,
    this.createdAt,
    this.service,
    this.staff,
  });

  factory MyBookingData.fromJson(Map<String, dynamic> json) =>
      _$MyBookingDataFromJson(json);
  Map<String, dynamic> toJson() => _$MyBookingDataToJson(this);
}

@JsonSerializable()
class MyBookingService {
  String? name;
  int? price;
  int? durationMinutes;

  MyBookingService({this.name, this.price, this.durationMinutes});

  factory MyBookingService.fromJson(Map<String, dynamic> json) =>
      _$MyBookingServiceFromJson(json);
  Map<String, dynamic> toJson() => _$MyBookingServiceToJson(this);
}

@JsonSerializable()
class MyBookingStaffInfo {
  int? id;
  MyBookingStaffUser? user;

  MyBookingStaffInfo({this.id, this.user});

  factory MyBookingStaffInfo.fromJson(Map<String, dynamic> json) =>
      _$MyBookingStaffInfoFromJson(json);
  Map<String, dynamic> toJson() => _$MyBookingStaffInfoToJson(this);
}

@JsonSerializable()
class MyBookingStaffUser {
  String? name;

  MyBookingStaffUser({this.name});

  factory MyBookingStaffUser.fromJson(Map<String, dynamic> json) =>
      _$MyBookingStaffUserFromJson(json);
  Map<String, dynamic> toJson() => _$MyBookingStaffUserToJson(this);
}
