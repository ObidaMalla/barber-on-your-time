import 'package:json_annotation/json_annotation.dart';

part 'delete_service_model.g.dart';

@JsonSerializable()
class DeleteServiceModel {
  bool? success;
  int? statusCode;
  String? message;
  dynamic data;

  DeleteServiceModel({this.success, this.statusCode, this.message, this.data});

  factory DeleteServiceModel.fromJson(Map<String, dynamic> json) =>
      _$DeleteServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeleteServiceModelToJson(this);
}
