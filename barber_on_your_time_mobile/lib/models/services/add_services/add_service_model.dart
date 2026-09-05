import 'package:json_annotation/json_annotation.dart';

part 'add_service_model.g.dart';

// Request Body Model
@JsonSerializable()
class AddServiceRequest {
  final String name;
  final int durationMinutes;
  final int price;

  AddServiceRequest({
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  factory AddServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$AddServiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AddServiceRequestToJson(this);
}

// Response Model
@JsonSerializable()
class AddServiceModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final AddServiceData? data;

  AddServiceModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory AddServiceModel.fromJson(Map<String, dynamic> json) =>
      _$AddServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddServiceModelToJson(this);
}

@JsonSerializable()
class AddServiceData {
  final int? id;
  final String? name;
  final int? durationMinutes;
  final int? price;
  final int? businessId;
  final String? createdAt;

  AddServiceData({
    this.id,
    this.name,
    this.durationMinutes,
    this.price,
    this.businessId,
    this.createdAt,
  });

  factory AddServiceData.fromJson(Map<String, dynamic> json) =>
      _$AddServiceDataFromJson(json);

  Map<String, dynamic> toJson() => _$AddServiceDataToJson(this);
}