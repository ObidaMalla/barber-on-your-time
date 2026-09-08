// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CompleteBookingModel _$CompleteBookingModelFromJson(
  Map<String, dynamic> json,
) => CompleteBookingModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : CompleteBookingData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CompleteBookingModelToJson(
  CompleteBookingModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

CompleteBookingData _$CompleteBookingDataFromJson(Map<String, dynamic> json) =>
    CompleteBookingData(
      id: (json['id'] as num?)?.toInt(),
      startTime: json['startTime'] as String?,
      status: json['status'] as String?,
      completionCode: json['completionCode'] as String?,
      customerId: (json['customerId'] as num?)?.toInt(),
      serviceId: (json['serviceId'] as num?)?.toInt(),
      staffId: (json['staffId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$CompleteBookingDataToJson(
  CompleteBookingData instance,
) => <String, dynamic>{
  'id': instance.id,
  'startTime': instance.startTime,
  'status': instance.status,
  'completionCode': instance.completionCode,
  'customerId': instance.customerId,
  'serviceId': instance.serviceId,
  'staffId': instance.staffId,
  'createdAt': instance.createdAt,
};
