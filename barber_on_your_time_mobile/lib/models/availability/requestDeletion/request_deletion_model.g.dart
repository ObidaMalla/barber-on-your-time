// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_deletion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestDeletionRequest _$RequestDeletionRequestFromJson(
  Map<String, dynamic> json,
) => RequestDeletionRequest(
  availabilityId: (json['availabilityId'] as num).toInt(),
);

Map<String, dynamic> _$RequestDeletionRequestToJson(
  RequestDeletionRequest instance,
) => <String, dynamic>{'availabilityId': instance.availabilityId};

RequestDeletionModel _$RequestDeletionModelFromJson(
  Map<String, dynamic> json,
) => RequestDeletionModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : RequestDeletionData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RequestDeletionModelToJson(
  RequestDeletionModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

RequestDeletionData _$RequestDeletionDataFromJson(Map<String, dynamic> json) =>
    RequestDeletionData(
      id: (json['id'] as num?)?.toInt(),
      type: json['type'] as String?,
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      status: json['status'] as String?,
      staffId: (json['staffId'] as num?)?.toInt(),
      availabilityId: (json['availabilityId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$RequestDeletionDataToJson(
  RequestDeletionData instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'status': instance.status,
  'staffId': instance.staffId,
  'availabilityId': instance.availabilityId,
  'createdAt': instance.createdAt,
};
