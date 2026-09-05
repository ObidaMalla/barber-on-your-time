import 'package:json_annotation/json_annotation.dart';

part 'get_availability_model.g.dart';

@JsonSerializable()
class GetAvailabilityModel {
  bool? success;
  int? statusCode;
  String? message;
  List<AvailabilityData>? data;

  GetAvailabilityModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$GetAvailabilityModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetAvailabilityModelToJson(this);
}

@JsonSerializable()
class AvailabilityData {
  int? id;
  int? dayOfWeek;
  String? startTime;
  String? endTime;
  int? staffId;

  AvailabilityData({
    this.id,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.staffId,
  });

  factory AvailabilityData.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityDataFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityDataToJson(this);
}
