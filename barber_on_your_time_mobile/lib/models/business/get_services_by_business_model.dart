import 'package:json_annotation/json_annotation.dart';

part 'get_services_by_business_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GetServicesByBusinessModel {
  bool? success;
  int? statusCode;
  String? message;
  List<ServiceData>? data;

  GetServicesByBusinessModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetServicesByBusinessModel.fromJson(Map<String, dynamic> json) =>
      _$GetServicesByBusinessModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetServicesByBusinessModelToJson(this);
}

@JsonSerializable()
class ServiceData {
  int? id;
  String? name;
  int? durationMinutes;
  int? price;
  int? businessId;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? createdAt;

  ServiceData({
    this.id,
    this.name,
    this.durationMinutes,
    this.price,
    this.businessId,
    this.createdAt,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) =>
      _$ServiceDataFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceDataToJson(this);

  static DateTime? _dateTimeFromJson(String? date) =>
      date != null ? DateTime.tryParse(date) : null;

  static String? _dateTimeToJson(DateTime? date) => date?.toIso8601String();
}
