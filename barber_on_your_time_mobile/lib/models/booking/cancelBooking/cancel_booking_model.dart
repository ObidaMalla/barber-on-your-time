import 'package:json_annotation/json_annotation.dart';

part 'cancel_booking_model.g.dart';

@JsonSerializable()
class CancelBookingModel {
  bool? success;
  int? statusCode;
  String? message;
  CancelBookingData? data;

  CancelBookingModel({this.success, this.statusCode, this.message, this.data});

  factory CancelBookingModel.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingModelFromJson(json);
  Map<String, dynamic> toJson() => _$CancelBookingModelToJson(this);
}

@JsonSerializable()
class CancelBookingData {
  int? id;
  String? startTime;
  String? status;
  int? customerId;
  int? serviceId;
  int? staffId;
  String? createdAt;

  CancelBookingData({
    this.id,
    this.startTime,
    this.status,
    this.customerId,
    this.serviceId,
    this.staffId,
    this.createdAt,
  });

  factory CancelBookingData.fromJson(Map<String, dynamic> json) =>
      _$CancelBookingDataFromJson(json);
  Map<String, dynamic> toJson() => _$CancelBookingDataToJson(this);
}
