import 'package:json_annotation/json_annotation.dart';

import 'get_owner_pending_requests_model.dart';

part 'answer_request_model.g.dart';

// Request Body Model
@JsonSerializable()
class AnswerRequestBody {
  final String decision; // "APPROVE" or "REJECT"

  AnswerRequestBody({required this.decision});

  factory AnswerRequestBody.fromJson(Map<String, dynamic> json) =>
      _$AnswerRequestBodyFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerRequestBodyToJson(this);
}

// Response Model
@JsonSerializable()
class AnswerRequestModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final OwnerPendingRequestData? data;

  AnswerRequestModel({this.success, this.statusCode, this.message, this.data});

  factory AnswerRequestModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerRequestModelToJson(this);
}
