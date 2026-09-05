import 'package:json_annotation/json_annotation.dart';

part 'business_model.g.dart';

@JsonSerializable()
class CreateBusinessModel {
  bool? success;
  int? statusCode;
  String? message;
  BusinessData? data;

  CreateBusinessModel({this.success, this.statusCode, this.message, this.data});

  factory CreateBusinessModel.fromJson(Map<String, dynamic> json) =>
      _$CreateBusinessModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreateBusinessModelToJson(this);
}

@JsonSerializable()
class BusinessData {
  int? id;
  String? name;
  String? address;
  int? ownerId;
  String? createdAt;

  BusinessData({
    this.id,
    this.name,
    this.address,
    this.ownerId,
    this.createdAt,
  });

  factory BusinessData.fromJson(Map<String, dynamic> json) =>
      _$BusinessDataFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessDataToJson(this);
}
