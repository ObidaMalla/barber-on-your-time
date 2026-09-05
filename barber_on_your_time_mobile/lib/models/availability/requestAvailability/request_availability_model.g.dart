// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestAvailabilityRequest _$RequestAvailabilityRequestFromJson(
  Map<String, dynamic> json,
) => RequestAvailabilityRequest(
  availabilityId: (json['availabilityId'] as num).toInt(),
  dayOfWeek: (json['dayOfWeek'] as num).toInt(),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
);

Map<String, dynamic> _$RequestAvailabilityRequestToJson(
  RequestAvailabilityRequest instance,
) => <String, dynamic>{
  'availabilityId': instance.availabilityId,
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
};

RequestAvailabilityModel _$RequestAvailabilityModelFromJson(
  Map<String, dynamic> json,
) => RequestAvailabilityModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : RequestAvailabilityData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RequestAvailabilityModelToJson(
  RequestAvailabilityModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

RequestAvailabilityData _$RequestAvailabilityDataFromJson(
  Map<String, dynamic> json,
) => RequestAvailabilityData(
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

Map<String, dynamic> _$RequestAvailabilityDataToJson(
  RequestAvailabilityData instance,
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
