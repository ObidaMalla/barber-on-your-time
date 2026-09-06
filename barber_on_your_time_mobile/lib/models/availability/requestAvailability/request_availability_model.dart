import 'package:json_annotation/json_annotation.dart';

part 'request_availability_model.g.dart';

@JsonSerializable()
class RequestAvailabilityRequest {
  final int availabilityId;
  final String date; // 👈 بدل dayOfWeek
  final String startTime;
  final String endTime;

  RequestAvailabilityRequest({
    required this.availabilityId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => _$RequestAvailabilityRequestToJson(this);
}

@JsonSerializable()
class RequestAvailabilityModel {
  bool? success;
  int? statusCode;
  String? message;
  RequestAvailabilityData? data;

  RequestAvailabilityModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory RequestAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$RequestAvailabilityModelFromJson(json);
  Map<String, dynamic> toJson() => _$RequestAvailabilityModelToJson(this);
}

@JsonSerializable()
class RequestAvailabilityData {
  int? id;
  String? type;
  String? date; // 👈 جديد
  int? dayOfWeek;
  String? startTime;
  String? endTime;
  String? status;
  int? staffId;
  int? availabilityId;

  RequestAvailabilityData({
    this.id,
    this.type,
    this.date,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.status,
    this.staffId,
    this.availabilityId,
  });

  factory RequestAvailabilityData.fromJson(Map<String, dynamic> json) =>
      _$RequestAvailabilityDataFromJson(json);
  Map<String, dynamic> toJson() => _$RequestAvailabilityDataToJson(this);
}
