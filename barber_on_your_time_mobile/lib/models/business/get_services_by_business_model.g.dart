// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_services_by_business_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetServicesByBusinessModel _$GetServicesByBusinessModelFromJson(
  Map<String, dynamic> json,
) => GetServicesByBusinessModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => ServiceData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetServicesByBusinessModelToJson(
  GetServicesByBusinessModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

ServiceData _$ServiceDataFromJson(Map<String, dynamic> json) => ServiceData(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
  price: (json['price'] as num?)?.toInt(),
  businessId: (json['businessId'] as num?)?.toInt(),
  createdAt: ServiceData._dateTimeFromJson(json['createdAt'] as String?),
);

Map<String, dynamic> _$ServiceDataToJson(ServiceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'businessId': instance.businessId,
      'createdAt': ServiceData._dateTimeToJson(instance.createdAt),
    };
