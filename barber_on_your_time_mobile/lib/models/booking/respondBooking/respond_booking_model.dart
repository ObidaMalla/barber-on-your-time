import 'package:json_annotation/json_annotation.dart';

part 'respond_booking_model.g.dart';

@JsonSerializable()
class RespondBookingModel {
  bool? success;
  int? statusCode;
  String? message;
  RespondBookingData? data;

  RespondBookingModel({this.success, this.statusCode, this.message, this.data});

  factory RespondBookingModel.fromJson(Map<String, dynamic> json) =>
      _$RespondBookingModelFromJson(json);
  Map<String, dynamic> toJson() => _$RespondBookingModelToJson(this);
}

@JsonSerializable()
class RespondBookingData {
  int? id;
  String? startTime;
  String? status;
  int? customerId;
  int? serviceId;
  int? staffId;
  String? createdAt;

  RespondBookingData({
    this.id,
    this.startTime,
    this.status,
    this.customerId,
    this.serviceId,
    this.staffId,
    this.createdAt,
  });

  factory RespondBookingData.fromJson(Map<String, dynamic> json) =>
      _$RespondBookingDataFromJson(json);
  Map<String, dynamic> toJson() => _$RespondBookingDataToJson(this);
}
