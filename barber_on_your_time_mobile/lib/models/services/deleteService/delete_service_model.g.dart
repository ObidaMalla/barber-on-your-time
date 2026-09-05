// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteServiceModel _$DeleteServiceModelFromJson(Map<String, dynamic> json) =>
    DeleteServiceModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$DeleteServiceModelToJson(DeleteServiceModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };
