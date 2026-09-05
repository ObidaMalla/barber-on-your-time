// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'respond_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RespondBookingModel _$RespondBookingModelFromJson(Map<String, dynamic> json) =>
    RespondBookingModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : RespondBookingData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RespondBookingModelToJson(
  RespondBookingModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

RespondBookingData _$RespondBookingDataFromJson(Map<String, dynamic> json) =>
    RespondBookingData(
      id: (json['id'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      status: json['status'] as String?,
      customerId: (json['customerId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      staffId: (json['staffId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$RespondBookingDataToJson(RespondBookingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime,
      'status': instance.status,
      'customerId': instance.customerId,
      'serviceId': instance.serviceId,
      'staffId': instance.staffId,
      'createdAt': instance.createdAt,
    };
