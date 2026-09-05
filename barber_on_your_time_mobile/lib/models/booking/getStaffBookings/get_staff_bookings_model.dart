import 'package:json_annotation/json_annotation.dart';

part 'get_staff_bookings_model.g.dart';

@JsonSerializable()
class GetStaffBookingsModel {
  bool? success;
  int? statusCode;
  String? message;
  List<StaffBookingData>? data;

  GetStaffBookingsModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetStaffBookingsModel.fromJson(Map<String, dynamic> json) =>
      _$GetStaffBookingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetStaffBookingsModelToJson(this);
}

@JsonSerializable()
class StaffBookingData {
  int? id;
  String? startTime;
  String? status;
  int? customerId;
  int? serviceId;
  int? staffId;
  String? createdAt;
  BookingCustomerInfo? customer;
  BookingServiceInfo? service;

  StaffBookingData({
    this.id,
    this.startTime,
    this.status,
    this.customerId,
    this.serviceId,
    this.staffId,
    this.createdAt,
    this.customer,
    this.service,
  });

  factory StaffBookingData.fromJson(Map<String, dynamic> json) =>
      _$StaffBookingDataFromJson(json);
  Map<String, dynamic> toJson() => _$StaffBookingDataToJson(this);
}

@JsonSerializable()
class BookingCustomerInfo {
  int? id;
  String? name;
  String? email;

  BookingCustomerInfo({this.id, this.name, this.email});

  factory BookingCustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$BookingCustomerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BookingCustomerInfoToJson(this);
}

@JsonSerializable()
class BookingServiceInfo {
  int? id;
  String? name;
  int? durationMinutes;
  double? price;
  int? businessId;
  String? createdAt;

  BookingServiceInfo({
    this.id,
    this.name,
    this.durationMinutes,
    this.price,
    this.businessId,
    this.createdAt,
  });

  factory BookingServiceInfo.fromJson(Map<String, dynamic> json) =>
      _$BookingServiceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BookingServiceInfoToJson(this);
}
