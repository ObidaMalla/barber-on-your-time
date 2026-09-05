// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddServiceRequest _$AddServiceRequestFromJson(Map<String, dynamic> json) =>
    AddServiceRequest(
      name: json['name'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$AddServiceRequestToJson(AddServiceRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
    };

AddServiceModel _$AddServiceModelFromJson(Map<String, dynamic> json) =>
    AddServiceModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : AddServiceData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AddServiceModelToJson(AddServiceModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

AddServiceData _$AddServiceDataFromJson(Map<String, dynamic> json) =>
    AddServiceData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toInt(),
      businessId: (json['businessId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$AddServiceDataToJson(AddServiceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'businessId': instance.businessId,
      'createdAt': instance.createdAt,
    };
