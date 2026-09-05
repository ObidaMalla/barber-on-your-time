// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_my_bookings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetMyBookingsModel _$GetMyBookingsModelFromJson(Map<String, dynamic> json) =>
    GetMyBookingsModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => MyBookingData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetMyBookingsModelToJson(GetMyBookingsModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

MyBookingData _$MyBookingDataFromJson(Map<String, dynamic> json) =>
    MyBookingData(
      id: (json['id'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      status: json['status'] as String?,
      customerId: (json['customerId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      staffId: (json['staffId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
      service: json['service'] == null
          ? null
          : MyBookingService.fromJson(json['service'] as Map<String, dynamic>),
      staff: json['staff'] == null
          ? null
          : MyBookingStaffInfo.fromJson(json['staff'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MyBookingDataToJson(MyBookingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime,
      'status': instance.status,
      'customerId': instance.customerId,
      'serviceId': instance.serviceId,
      'staffId': instance.staffId,
      'createdAt': instance.createdAt,
      'service': instance.service,
      'staff': instance.staff,
    };

MyBookingService _$MyBookingServiceFromJson(Map<String, dynamic> json) =>
    MyBookingService(
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toInt(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MyBookingServiceToJson(MyBookingService instance) =>
    <String, dynamic>{
      'name': instance.name,
      'price': instance.price,
      'durationMinutes': instance.durationMinutes,
    };

MyBookingStaffInfo _$MyBookingStaffInfoFromJson(Map<String, dynamic> json) =>
    MyBookingStaffInfo(
      id: (json['id'] as num?)?.toInt(),
      user: json['user'] == null
          ? null
          : MyBookingStaffUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MyBookingStaffInfoToJson(MyBookingStaffInfo instance) =>
    <String, dynamic>{'id': instance.id, 'user': instance.user};

MyBookingStaffUser _$MyBookingStaffUserFromJson(Map<String, dynamic> json) =>
    MyBookingStaffUser(name: json['name'] as String?);

Map<String, dynamic> _$MyBookingStaffUserToJson(MyBookingStaffUser instance) =>
    <String, dynamic>{'name': instance.name};
