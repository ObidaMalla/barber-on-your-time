import 'package:json_annotation/json_annotation.dart';

part 'get_services_model.g.dart';

@JsonSerializable()
class GetServicesModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final List<ServiceData>? data;

  GetServicesModel({this.success, this.statusCode, this.message, this.data});

  factory GetServicesModel.fromJson(Map<String, dynamic> json) =>
      _$GetServicesModelFromJson(json);

  Map<String, dynamic> toJson() => _$GetServicesModelToJson(this);
}

@JsonSerializable()
class ServiceData {
  final int? id;
  final String? name;
  final int? durationMinutes;
  final int? price;
  final int? businessId;
  final String? createdAt;

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
}
