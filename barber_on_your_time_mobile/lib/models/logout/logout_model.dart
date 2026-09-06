import 'package:json_annotation/json_annotation.dart';

part 'logout_model.g.dart';

@JsonSerializable()
class LogoutModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final dynamic data;

  LogoutModel({this.success, this.statusCode, this.message, this.data});

  factory LogoutModel.fromJson(Map<String, dynamic> json) {
    return LogoutModel(
      success: json['success'] as bool?,
      statusCode: json['statusCode'] as int?,
      message: json['message'] as String?,
      data: json['data'],
    );
  }
}
