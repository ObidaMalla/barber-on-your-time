// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateBookingModel _$CreateBookingModelFromJson(Map<String, dynamic> json) =>
    CreateBookingModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : CreateBookingData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateBookingModelToJson(CreateBookingModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

CreateBookingData _$CreateBookingDataFromJson(Map<String, dynamic> json) =>
    CreateBookingData(
      id: (json['id'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      status: json['status'] as String?,
      customerId: (json['customerId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      staffId: (json['staffId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      staff: json['staff'] == null
          ? null
          : BookingStaffInfo.fromJson(json['staff'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CreateBookingDataToJson(CreateBookingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime,
      'status': instance.status,
      'customerId': instance.customerId,
      'serviceId': instance.serviceId,
      'staffId': instance.staffId,
      'createdAt': instance.createdAt,
      'staff': instance.staff,
    };

BookingStaffInfo _$BookingStaffInfoFromJson(Map<String, dynamic> json) =>
    BookingStaffInfo(
      id: (json['id'] as num?)?.toInt(),
      active: json['active'] as bool?,
      userId: (json['userId'] as num?)?.toInt(),
      businessId: (json['businessId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      user: json['user'] == null
          ? null
          : BookingStaffUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookingStaffInfoToJson(BookingStaffInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'active': instance.active,
      'userId': instance.userId,
      'businessId': instance.businessId,
      'createdAt': instance.createdAt,
      'user': instance.user,
    };

BookingStaffUser _$BookingStaffUserFromJson(Map<String, dynamic> json) =>
    BookingStaffUser(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$BookingStaffUserToJson(BookingStaffUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
    };
