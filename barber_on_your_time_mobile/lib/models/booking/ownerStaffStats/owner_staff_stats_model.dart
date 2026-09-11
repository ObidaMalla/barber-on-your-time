import 'package:json_annotation/json_annotation.dart';

part 'owner_staff_stats_model.g.dart';

@JsonSerializable()
class OwnerStaffStatsModel {
  bool? success;
  int? statusCode;
  String? message;
  OwnerStaffStatsData? data;

  OwnerStaffStatsModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory OwnerStaffStatsModel.fromJson(Map<String, dynamic> json) =>
      _$OwnerStaffStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerStaffStatsModelToJson(this);
}

@JsonSerializable()
class OwnerStaffStatsData {
  OwnerStaffWeeklyStatsData? thisWeek;
  int? totalServicesRejected;
  int? totalServicesCompleted;

  OwnerStaffStatsData({
    this.thisWeek,
    this.totalServicesRejected,
    this.totalServicesCompleted,
  });

  factory OwnerStaffStatsData.fromJson(Map<String, dynamic> json) =>
      _$OwnerStaffStatsDataFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerStaffStatsDataToJson(this);
}

@JsonSerializable()
class OwnerStaffWeeklyStatsData {
  num? revenue;
  num? hoursWorked;

  OwnerStaffWeeklyStatsData({this.revenue, this.hoursWorked});

  factory OwnerStaffWeeklyStatsData.fromJson(Map<String, dynamic> json) =>
      _$OwnerStaffWeeklyStatsDataFromJson(json);

  Map<String, dynamic> toJson() => _$OwnerStaffWeeklyStatsDataToJson(this);

  String get formattedWorkedTime {
    final hoursValue = hoursWorked ?? 0;
    final totalMinutes = (hoursValue * 60).round();

    if (totalMinutes < 60) return '$totalMinutes دقيقة';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) return '$hours ساعة';
    return '$hours ساعة و$minutes دقيقة';
  }
}
