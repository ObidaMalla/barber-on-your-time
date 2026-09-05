import 'package:json_annotation/json_annotation.dart';

part 'create_booking_model.g.dart';

@JsonSerializable()
class CreateBookingModel {
  bool? success;
  int? statusCode;
  String? message;
  CreateBookingData? data;

  CreateBookingModel({this.success, this.statusCode, this.message, this.data});

  factory CreateBookingModel.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingModelFromJson(json);
  Map<String, dynamic> toJson() => _$CreateBookingModelToJson(this);
}

@JsonSerializable()
class CreateBookingData {
  int? id;
  String? startTime;
  String? status;
  int? customerId;
  int? serviceId;
  int? staffId;
  String? createdAt;
  BookingStaffInfo? staff;

  CreateBookingData({
    this.id,
    this.startTime,
    this.status,
    this.customerId,
    this.serviceId,
    this.staffId,
    this.createdAt,
    this.staff,
  });

  factory CreateBookingData.fromJson(Map<String, dynamic> json) =>
      _$CreateBookingDataFromJson(json);
  Map<String, dynamic> toJson() => _$CreateBookingDataToJson(this);
}

@JsonSerializable()
class BookingStaffInfo {
  int? id;
  bool? active;
  int? userId;
  int? businessId;
  String? createdAt;
  BookingStaffUser? user;

  BookingStaffInfo({
    this.id,
    this.active,
    this.userId,
    this.businessId,
    this.createdAt,
    this.user,
  });

  factory BookingStaffInfo.fromJson(Map<String, dynamic> json) =>
      _$BookingStaffInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BookingStaffInfoToJson(this);
}

@JsonSerializable()
class BookingStaffUser {
  int? id;
  String? name;
  String? email;
  String? role;

  BookingStaffUser({this.id, this.name, this.email, this.role});

  factory BookingStaffUser.fromJson(Map<String, dynamic> json) =>
      _$BookingStaffUserFromJson(json);
  Map<String, dynamic> toJson() => _$BookingStaffUserToJson(this);
}
