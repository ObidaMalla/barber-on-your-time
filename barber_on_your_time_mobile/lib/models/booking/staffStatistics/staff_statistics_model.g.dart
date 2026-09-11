// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StaffStatisticsModel _$StaffStatisticsModelFromJson(
  Map<String, dynamic> json,
) => StaffStatisticsModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : StaffStatisticsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$StaffStatisticsModelToJson(
  StaffStatisticsModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

StaffStatisticsData _$StaffStatisticsDataFromJson(Map<String, dynamic> json) =>
    StaffStatisticsData(
      thisWeek: json['thisWeek'] == null
          ? null
          : ThisWeekStaffStatisticsData.fromJson(
              json['thisWeek'] as Map<String, dynamic>,
            ),
      totalServicesRejected: (json['totalServicesRejected'] as num?)?.toInt(),
      totalServicesCompleted: (json['totalServicesCompleted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StaffStatisticsDataToJson(
  StaffStatisticsData instance,
) => <String, dynamic>{
  'thisWeek': instance.thisWeek,
  'totalServicesRejected': instance.totalServicesRejected,
  'totalServicesCompleted': instance.totalServicesCompleted,
};

ThisWeekStaffStatisticsData _$ThisWeekStaffStatisticsDataFromJson(
  Map<String, dynamic> json,
) => ThisWeekStaffStatisticsData(
  revenue: json['revenue'] as num?,
  hoursWorked: (json['hoursWorked'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ThisWeekStaffStatisticsDataToJson(
  ThisWeekStaffStatisticsData instance,
) => <String, dynamic>{
  'revenue': instance.revenue,
  'hoursWorked': instance.hoursWorked,
};
