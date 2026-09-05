// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_staff_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetStaffModel _$GetStaffModelFromJson(Map<String, dynamic> json) =>
    GetStaffModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StaffData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetStaffModelToJson(GetStaffModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

StaffData _$StaffDataFromJson(Map<String, dynamic> json) => StaffData(
  id: (json['id'] as num?)?.toInt(),
  active: json['active'] as bool?,
  createdAt: json['createdAt'] as String?,
  user: json['user'] == null
      ? null
      : StaffUser.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StaffDataToJson(StaffData instance) => <String, dynamic>{
  'id': instance.id,
  'active': instance.active,
  'createdAt': instance.createdAt,
  'user': instance.user,
};

StaffUser _$StaffUserFromJson(Map<String, dynamic> json) => StaffUser(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  email: json['email'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$StaffUserToJson(StaffUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role': instance.role,
};
