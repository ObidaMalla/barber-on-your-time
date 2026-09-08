import 'package:json_annotation/json_annotation.dart';

part 'complete_booking_model.g.dart';

@JsonSerializable()
class CompleteBookingModel {
  bool? success;
  int? statusCode;
  String? message;
  CompleteBookingData? data;

  CompleteBookingModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory CompleteBookingModel.fromJson(Map<String, dynamic> json) =>
      _$CompleteBookingModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompleteBookingModelToJson(this);
}

@JsonSerializable()
class CompleteBookingData {
  int? id;
  String? startTime;
  String? status;
  String? completionCode;
  int? customerId;
  int? serviceId;
  int? staffId;
  String? createdAt;

  CompleteBookingData({
    this.id,
    this.startTime,
    this.status,
    this.completionCode,
    this.customerId,
    this.serviceId,
    this.staffId,
    this.createdAt,
  });

  factory CompleteBookingData.fromJson(Map<String, dynamic> json) =>
      _$CompleteBookingDataFromJson(json);
  Map<String, dynamic> toJson() => _$CompleteBookingDataToJson(this);
}
