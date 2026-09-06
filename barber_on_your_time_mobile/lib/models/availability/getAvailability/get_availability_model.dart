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
  String? date; // 👈 تم إضافة حقل التاريخ هنا
  int? dayOfWeek;
  String? startTime;
  String? endTime;
  int? staffId;

  AvailabilityData({
    this.id,
    this.date, // 👈 إضافته في الـ Constructor
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.staffId,
  });

  factory AvailabilityData.fromJson(Map<String, dynamic> json) =>
      _$AvailabilityDataFromJson(json);
  Map<String, dynamic> toJson() => _$AvailabilityDataToJson(this);
}
