// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_all_businesses_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllBusinessesModel _$GetAllBusinessesModelFromJson(
  Map<String, dynamic> json,
) => GetAllBusinessesModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => BusinessData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetAllBusinessesModelToJson(
  GetAllBusinessesModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

BusinessData _$BusinessDataFromJson(Map<String, dynamic> json) => BusinessData(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  address: json['address'] as String?,
  createdAt: BusinessData._dateTimeFromJson(json['createdAt'] as String?),
  owner: json['owner'] == null
      ? null
      : BusinessOwner.fromJson(json['owner'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BusinessDataToJson(BusinessData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'createdAt': BusinessData._dateTimeToJson(instance.createdAt),
      'owner': instance.owner?.toJson(),
    };

BusinessOwner _$BusinessOwnerFromJson(Map<String, dynamic> json) =>
    BusinessOwner(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$BusinessOwnerToJson(BusinessOwner instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };
