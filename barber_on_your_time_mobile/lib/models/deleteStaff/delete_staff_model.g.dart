// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_staff_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteStaffModel _$DeleteStaffModelFromJson(Map<String, dynamic> json) =>
    DeleteStaffModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
    );

Map<String, dynamic> _$DeleteStaffModelToJson(DeleteStaffModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
    };
