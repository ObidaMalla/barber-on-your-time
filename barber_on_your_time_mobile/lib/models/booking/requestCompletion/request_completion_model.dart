import 'package:json_annotation/json_annotation.dart';

part 'request_completion_model.g.dart';

@JsonSerializable()
class RequestCompletionModel {
  bool? success;
  int? statusCode;
  String? message;
  dynamic data;

  RequestCompletionModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory RequestCompletionModel.fromJson(Map<String, dynamic> json) =>
      _$RequestCompletionModelFromJson(json);
  Map<String, dynamic> toJson() => _$RequestCompletionModelToJson(this);
}
