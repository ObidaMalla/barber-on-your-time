import 'package:json_annotation/json_annotation.dart';

part 'add_availability_model.g.dart';

@JsonSerializable()
class AddAvailabilityRequest {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  AddAvailabilityRequest({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() => _$AddAvailabilityRequestToJson(this);
}

@JsonSerializable()
class AddAvailabilityModel {
  bool? success;
  int? statusCode;
  String? message;
  AvailabilityItemData? data;

  AddAvailabilityModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory AddAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      _$AddAvailabilityModelFromJson(json);
  Map<String, dynamic> toJson() => _$AddAvailabilityModelToJson(this);
}

@JsonSerializable()
class AvailabilityItemData {
  int? id;
  int? dayOfWeek;
  String? startTime;
  String? endTime;
  int? staffId;

  AvailabilityItemData({
    this.id,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.staffId,
  });

  factory AvailabilityItemData.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityItemDataFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityItemDataToJson(this);
}
