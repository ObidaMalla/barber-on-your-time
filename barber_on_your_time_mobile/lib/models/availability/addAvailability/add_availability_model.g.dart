// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddAvailabilityRequest _$AddAvailabilityRequestFromJson(
  Map<String, dynamic> json,
) => AddAvailabilityRequest(
  dayOfWeek: (json['dayOfWeek'] as num).toInt(),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
);

Map<String, dynamic> _$AddAvailabilityRequestToJson(
  AddAvailabilityRequest instance,
) => <String, dynamic>{
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
};

AddAvailabilityModel _$AddAvailabilityModelFromJson(
  Map<String, dynamic> json,
) => AddAvailabilityModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : AvailabilityItemData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AddAvailabilityModelToJson(
  AddAvailabilityModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

AvailabilityItemData _$AvailabilityItemDataFromJson(
  Map<String, dynamic> json,
) => AvailabilityItemData(
  id: (json['id'] as num?)?.toInt(),
  dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  staffId: (json['staffId'] as num?)?.toInt(),
);

Map<String, dynamic> _$AvailabilityItemDataToJson(
  AvailabilityItemData instance,
) => <String, dynamic>{
  'id': instance.id,
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'staffId': instance.staffId,
};
