// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_staff_by_business_id_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetStaffByBusinessIdModel _$GetStaffByBusinessIdModelFromJson(
  Map<String, dynamic> json,
) => GetStaffByBusinessIdModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => StaffMemberData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetStaffByBusinessIdModelToJson(
  GetStaffByBusinessIdModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data?.map((e) => e.toJson()).toList(),
};

StaffMemberData _$StaffMemberDataFromJson(Map<String, dynamic> json) =>
    StaffMemberData(
      id: (json['id'] as num?)?.toInt(),
      active: json['active'] as bool?,
      createdAt: StaffMemberData._dateTimeFromJson(
        json['createdAt'] as String?,
      ),
      user: json['user'] == null
          ? null
          : StaffUserProfile.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StaffMemberDataToJson(StaffMemberData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'createdAt': StaffMemberData._dateTimeToJson(instance.createdAt),
      'user': instance.user?.toJson(),
    };

StaffUserProfile _$StaffUserProfileFromJson(Map<String, dynamic> json) =>
    StaffUserProfile(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$StaffUserProfileToJson(StaffUserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };
