// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_services_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetServicesModel _$GetServicesModelFromJson(Map<String, dynamic> json) =>
    GetServicesModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ServiceData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetServicesModelToJson(GetServicesModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

ServiceData _$ServiceDataFromJson(Map<String, dynamic> json) => ServiceData(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toInt(),
  businessId: (json['businessId'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$ServiceDataToJson(ServiceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'businessId': instance.businessId,
      'createdAt': instance.createdAt,
    };
