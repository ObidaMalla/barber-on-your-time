// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_staff_bookings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetStaffBookingsModel _$GetStaffBookingsModelFromJson(
  Map<String, dynamic> json,
) => GetStaffBookingsModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: (json['data'] as List<dynamic>?)
      ?.map((e) => StaffBookingData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GetStaffBookingsModelToJson(
  GetStaffBookingsModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

StaffBookingData _$StaffBookingDataFromJson(
  Map<String, dynamic> json,
) => StaffBookingData(
  id: (json['id'] as num?)?.toInt(),
  startTime: json['startTime'] as String?,
  status: json['status'] as String?,
  customerId: (json['customerId'] as num?)?.toInt(),
  serviceId: (json['serviceId'] as num?)?.toInt(),
  staffId: (json['staffId'] as num?)?.toInt(),
  createdAt: json['createdAt'] as String?,
  customer: json['customer'] == null
      ? null
      : BookingCustomerInfo.fromJson(json['customer'] as Map<String, dynamic>),
  service: json['service'] == null
      ? null
      : BookingServiceInfo.fromJson(json['service'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StaffBookingDataToJson(StaffBookingData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime,
      'status': instance.status,
      'customerId': instance.customerId,
      'serviceId': instance.serviceId,
      'staffId': instance.staffId,
      'createdAt': instance.createdAt,
      'customer': instance.customer,
      'service': instance.service,
    };

BookingCustomerInfo _$BookingCustomerInfoFromJson(Map<String, dynamic> json) =>
    BookingCustomerInfo(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$BookingCustomerInfoToJson(
  BookingCustomerInfo instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
};

BookingServiceInfo _$BookingServiceInfoFromJson(Map<String, dynamic> json) =>
    BookingServiceInfo(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toDouble(),
      businessId: (json['businessId'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$BookingServiceInfoToJson(BookingServiceInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'durationMinutes': instance.durationMinutes,
      'price': instance.price,
      'businessId': instance.businessId,
      'createdAt': instance.createdAt,
    };
