// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelBookingModel _$CancelBookingModelFromJson(Map<String, dynamic> json) =>
    CancelBookingModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : CancelBookingData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CancelBookingModelToJson(CancelBookingModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

CancelBookingData _$CancelBookingDataFromJson(Map<String, dynamic> json) =>
    CancelBookingData(
      id: (json['id'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      status: json['status'] as String?,
      customerId: (json['customerId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      staffId: (json['staffId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$CancelBookingDataToJson(CancelBookingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime,
      'status': instance.status,
      'customerId': instance.customerId,
      'serviceId': instance.serviceId,
      'staffId': instance.staffId,
      'createdAt': instance.createdAt,
    };
