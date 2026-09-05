// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateServiceRequest _$UpdateServiceRequestFromJson(
  Map<String, dynamic> json,
) => UpdateServiceRequest(
  name: json['name'] as String,
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
);

Map<String, dynamic> _$UpdateServiceRequestToJson(
  UpdateServiceRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'durationMinutes': instance.durationMinutes,
  'price': instance.price,
};

UpdateServiceModel _$UpdateServiceModelFromJson(Map<String, dynamic> json) =>
    UpdateServiceModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : UpdateServiceData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UpdateServiceModelToJson(UpdateServiceModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

UpdateServiceData _$UpdateServiceDataFromJson(Map<String, dynamic> json) =>
    UpdateServiceData(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      businessId: (json['businessId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$UpdateServiceDataToJson(UpdateServiceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'businessId': instance.businessId,
      'createdAt': instance.createdAt,
    };
