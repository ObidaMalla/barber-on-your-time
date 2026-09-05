import 'package:json_annotation/json_annotation.dart';

part 'update_service_model.g.dart';

@JsonSerializable()
class UpdateServiceRequest {
  final String name;
  final int durationMinutes;
  final double price;

  UpdateServiceRequest({
    required this.name,
    required this.durationMinutes,
    required this.price,
  });

  factory UpdateServiceRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateServiceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateServiceRequestToJson(this);
}

@JsonSerializable()
class UpdateServiceModel {
  bool? success;
  int? statusCode;
  String? message;
  UpdateServiceData? data;

  UpdateServiceModel({this.success, this.statusCode, this.message, this.data});

  factory UpdateServiceModel.fromJson(Map<String, dynamic> json) =>
      _$UpdateServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateServiceModelToJson(this);
}

@JsonSerializable()
class UpdateServiceData {
  int? id;
  String? name;
  int? durationMinutes;
  double? price;
  int? businessId;
  String? createdAt;

  UpdateServiceData({
    this.id,
    this.name,
    this.durationMinutes,
    this.price,
    this.businessId,
    this.createdAt,
  });

  factory UpdateServiceData.fromJson(Map<String, dynamic> json) =>
      _$UpdateServiceDataFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateServiceDataToJson(this);
}
