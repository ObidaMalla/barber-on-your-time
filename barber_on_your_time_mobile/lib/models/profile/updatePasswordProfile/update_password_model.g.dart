// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_password_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePasswordModel _$UpdatePasswordModelFromJson(Map<String, dynamic> json) =>
    UpdatePasswordModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'],
    );

Map<String, dynamic> _$UpdatePasswordModelToJson(
  UpdatePasswordModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};
