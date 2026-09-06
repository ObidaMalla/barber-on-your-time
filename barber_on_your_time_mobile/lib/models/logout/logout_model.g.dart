// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'logout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LogoutModel _$LogoutModelFromJson(Map<String, dynamic> json) => LogoutModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$LogoutModelToJson(LogoutModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };
