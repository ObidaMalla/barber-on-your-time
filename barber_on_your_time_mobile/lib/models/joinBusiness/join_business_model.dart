import 'package:json_annotation/json_annotation.dart';

part 'join_business_model.g.dart';

@JsonSerializable()
class JoinBusinessModel {
  bool? success;
  int? statusCode;
  String? message;
  JoinBusinessData? data;

  JoinBusinessModel({this.success, this.statusCode, this.message, this.data});

  factory JoinBusinessModel.fromJson(Map<String, dynamic> json) =>
      _$JoinBusinessModelFromJson(json);
  Map<String, dynamic> toJson() => _$JoinBusinessModelToJson(this);
}

@JsonSerializable()
class JoinBusinessData {
  int? id;
  bool? active;
  int? userId;
  int? businessId;
  String? createdAt;

  JoinBusinessData({
    this.id,
    this.active,
    this.userId,
    this.businessId,
    this.createdAt,
  });

  factory JoinBusinessData.fromJson(Map<String, dynamic> json) =>
      _$JoinBusinessDataFromJson(json);
  Map<String, dynamic> toJson() => _$JoinBusinessDataToJson(this);
}
