import 'package:json_annotation/json_annotation.dart';

part 'request_deletion_model.g.dart';

// Request Body Model
@JsonSerializable()
class RequestDeletionRequest {
  final int availabilityId;

  RequestDeletionRequest({required this.availabilityId});

  factory RequestDeletionRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestDeletionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestDeletionRequestToJson(this);
}

// Response Model
@JsonSerializable()
class RequestDeletionModel {
  final bool? success;
  final int? statusCode;
  final String? message;
  final RequestDeletionData? data;

  RequestDeletionModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory RequestDeletionModel.fromJson(Map<String, dynamic> json) =>
      _$RequestDeletionModelFromJson(json);

  Map<String, dynamic> toJson() => _$RequestDeletionModelToJson(this);
}

@JsonSerializable()
class RequestDeletionData {
  final int? id;
  final String? type;
  final int? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final String? status;
  final int? staffId;
  final int? availabilityId;
  final String? createdAt;

  RequestDeletionData({
    this.id,
    this.type,
    this.dayOfWeek,
    this.startTime,
    this.endTime,
    this.status,
    this.staffId,
    this.availabilityId,
    this.createdAt,
  });

  factory RequestDeletionData.fromJson(Map<String, dynamic> json) =>
      _$RequestDeletionDataFromJson(json);

  Map<String, dynamic> toJson() => _$RequestDeletionDataToJson(this);
}
