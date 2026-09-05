// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'join_business_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JoinBusinessModel _$JoinBusinessModelFromJson(Map<String, dynamic> json) =>
    JoinBusinessModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : JoinBusinessData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JoinBusinessModelToJson(JoinBusinessModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

JoinBusinessData _$JoinBusinessDataFromJson(Map<String, dynamic> json) =>
    JoinBusinessData(
      id: (json['id'] as num?)?.toInt(),
      active: json['active'] as bool?,
      userId: (json['userId'] as num?)?.toInt(),
      businessId: (json['businessId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$JoinBusinessDataToJson(JoinBusinessData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'userId': instance.userId,
      'businessId': instance.businessId,
      'createdAt': instance.createdAt,
    };
