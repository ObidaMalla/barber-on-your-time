// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_pending_requests_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetPendingRequestsModel _$GetPendingRequestsModelFromJson(
  Map<String, dynamic> json,
) => GetPendingRequestsModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => RequestAvailabilityData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetPendingRequestsModelToJson(
  GetPendingRequestsModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};
