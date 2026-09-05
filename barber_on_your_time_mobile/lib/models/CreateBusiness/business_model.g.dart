// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBusinessModel _$CreateBusinessModelFromJson(Map<String, dynamic> json) =>
    CreateBusinessModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : BusinessData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateBusinessModelToJson(
  CreateBusinessModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

BusinessData _$BusinessDataFromJson(Map<String, dynamic> json) => BusinessData(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  address: json['address'] as String?,
  ownerId: (json['ownerId'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$BusinessDataToJson(BusinessData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'ownerId': instance.ownerId,
      'createdAt': instance.createdAt,
    };
