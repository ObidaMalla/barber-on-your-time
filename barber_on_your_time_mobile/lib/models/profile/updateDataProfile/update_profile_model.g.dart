// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileModel _$UpdateProfileModelFromJson(Map<String, dynamic> json) =>
    UpdateProfileModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : UpdateProfileData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateProfileModelToJson(UpdateProfileModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

UpdateProfileData _$UpdateProfileDataFromJson(Map<String, dynamic> json) =>
    UpdateProfileData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$UpdateProfileDataToJson(UpdateProfileData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };
