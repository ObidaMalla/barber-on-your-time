import 'package:json_annotation/json_annotation.dart';

import 'request_availability_model.dart';

part 'get_pending_requests_model.g.dart';

@JsonSerializable()
class GetPendingRequestsModel {
  bool? success;
  int? statusCode;
  String? message;
  List<RequestAvailabilityData>? data;

  GetPendingRequestsModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory GetPendingRequestsModel.fromJson(Map<String, dynamic> json) =>
      _$GetPendingRequestsModelFromJson(json);
  Map<String, dynamic> toJson() => _$GetPendingRequestsModelToJson(this);
}
