// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_owner_pending_requests_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetOwnerPendingRequestsModel _$GetOwnerPendingRequestsModelFromJson(
  Map<String, dynamic> json,
) => GetOwnerPendingRequestsModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => OwnerPendingRequestData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetOwnerPendingRequestsModelToJson(
  GetOwnerPendingRequestsModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

OwnerPendingRequestData _$OwnerPendingRequestDataFromJson(
  Map<String, dynamic> json,
) => OwnerPendingRequestData(
  id: (json['id'] as num?)?.toInt(),
  type: json['type'] as String?,
  dayOfWeek: (json['dayOfWeek'] as num?)?.toInt(),
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  status: json['status'] as String?,
  staffId: (json['staffId'] as num?)?.toInt(),
  availabilityId: (json['availabilityId'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
  staff: json['staff'] == null
      ? null
      : RequestStaffInfo.fromJson(json['staff'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OwnerPendingRequestDataToJson(
  OwnerPendingRequestData instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': instance.type,
  'dayOfWeek': instance.dayOfWeek,
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'status': instance.status,
  'staffId': instance.staffId,
  'availabilityId': instance.availabilityId,
  'createdAt': instance.createdAt,
  'staff': instance.staff,
};

RequestStaffInfo _$RequestStaffInfoFromJson(Map<String, dynamic> json) =>
    RequestStaffInfo(
      id: (json['id'] as num?)?.toInt(),
      userId: (json['userId'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : RequestStaffUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RequestStaffInfoToJson(RequestStaffInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'user': instance.user,
    };

RequestStaffUser _$RequestStaffUserFromJson(Map<String, dynamic> json) =>
    RequestStaffUser(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$RequestStaffUserToJson(RequestStaffUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };
