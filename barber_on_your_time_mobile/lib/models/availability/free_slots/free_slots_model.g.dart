// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_slots_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeSlotsModel _$FreeSlotsModelFromJson(Map<String, dynamic> json) =>
    FreeSlotsModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => FreeSlotDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FreeSlotsModelToJson(FreeSlotsModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

FreeSlotDay _$FreeSlotDayFromJson(Map<String, dynamic> json) => FreeSlotDay(
  date: json['date'] as String?,
  workingHours: json['workingHours'] == null
      ? null
      : WorkingHours.fromJson(json['workingHours'] as Map<String, dynamic>),
  freeWindows: (json['freeWindows'] as List<dynamic>?)
      ?.map((e) => FreeWindow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FreeSlotDayToJson(FreeSlotDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'workingHours': instance.workingHours,
      'freeWindows': instance.freeWindows,
    };

WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) => WorkingHours(
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
);

Map<String, dynamic> _$WorkingHoursToJson(WorkingHours instance) =>
    <String, dynamic>{
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

FreeWindow _$FreeWindowFromJson(Map<String, dynamic> json) =>
    FreeWindow(from: json['from'] as String?, to: json['to'] as String?);

Map<String, dynamic> _$FreeWindowToJson(FreeWindow instance) =>
    <String, dynamic>{'from': instance.from, 'to': instance.to};
