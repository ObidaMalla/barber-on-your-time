// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_staff_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OwnerStaffStatsModel _$OwnerStaffStatsModelFromJson(
  Map<String, dynamic> json,
) => OwnerStaffStatsModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'] == null
      ? null
      : OwnerStaffStatsData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OwnerStaffStatsModelToJson(
  OwnerStaffStatsModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};

OwnerStaffStatsData _$OwnerStaffStatsDataFromJson(Map<String, dynamic> json) =>
    OwnerStaffStatsData(
      thisWeek: json['thisWeek'] == null
          ? null
          : OwnerStaffWeeklyStatsData.fromJson(
              json['thisWeek'] as Map<String, dynamic>,
            ),
      totalServicesRejected: (json['totalServicesRejected'] as num?)?.toInt(),
      totalServicesCompleted: (json['totalServicesCompleted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$OwnerStaffStatsDataToJson(
  OwnerStaffStatsData instance,
) => <String, dynamic>{
  'thisWeek': instance.thisWeek,
  'totalServicesRejected': instance.totalServicesRejected,
  'totalServicesCompleted': instance.totalServicesCompleted,
};

OwnerStaffWeeklyStatsData _$OwnerStaffWeeklyStatsDataFromJson(
  Map<String, dynamic> json,
) => OwnerStaffWeeklyStatsData(
  revenue: json['revenue'] as num?,
  hoursWorked: json['hoursWorked'] as num?,
);

Map<String, dynamic> _$OwnerStaffWeeklyStatsDataToJson(
  OwnerStaffWeeklyStatsData instance,
) => <String, dynamic>{
  'revenue': instance.revenue,
  'hoursWorked': instance.hoursWorked,
};
