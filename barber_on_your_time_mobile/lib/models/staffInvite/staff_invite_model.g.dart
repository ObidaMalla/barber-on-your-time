// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_invite_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffInviteModel _$StaffInviteModelFromJson(Map<String, dynamic> json) =>
    StaffInviteModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : StaffInviteData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StaffInviteModelToJson(StaffInviteModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

StaffInviteData _$StaffInviteDataFromJson(Map<String, dynamic> json) =>
    StaffInviteData(code: json['code'] as String?);

Map<String, dynamic> _$StaffInviteDataToJson(StaffInviteData instance) =>
    <String, dynamic>{'code': instance.code};
