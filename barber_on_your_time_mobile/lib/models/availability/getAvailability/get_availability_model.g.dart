// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_availability_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAvailabilityModel _$GetAvailabilityModelFromJson(
  Map<String, dynamic> json,
) => GetAvailabilityModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => AvailabilityData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetAvailabilityModelToJson(
  GetAvailabilityModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

AvailabilityData _$AvailabilityDataFromJson(Map<String, dynamic> json) =>
    AvailabilityData(
      id: (json['id'] as num?)?.toInt(),
      date: json['date'] as String?,
      dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      staffId: (json['staffId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AvailabilityDataToJson(AvailabilityData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'dayOfWeek': instance.dayOfWeek,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'staffId': instance.staffId,
    };
