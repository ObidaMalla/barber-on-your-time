import 'package:json_annotation/json_annotation.dart';

part 'staff_statistics_model.g.dart';

@JsonSerializable()
class StaffStatisticsModel {
  bool? success;
  int? statusCode;
  String? message;
  StaffStatisticsData? data;

  StaffStatisticsModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory StaffStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$StaffStatisticsModelFromJson(json);
  Map<String, dynamic> toJson() => _$StaffStatisticsModelToJson(this);
}

@JsonSerializable()
class StaffStatisticsData {
  ThisWeekStaffStatisticsData? thisWeek;
  int? totalServicesRejected;
  int? totalServicesCompleted;

  StaffStatisticsData({
    this.thisWeek,
    this.totalServicesRejected,
    this.totalServicesCompleted,
  });

  factory StaffStatisticsData.fromJson(Map<String, dynamic> json) =>
      _$StaffStatisticsDataFromJson(json);
  Map<String, dynamic> toJson() => _$StaffStatisticsDataToJson(this);
}

@JsonSerializable()
class ThisWeekStaffStatisticsData {
  num? revenue;
  double? hoursWorked; // 👈 زي ما هي من الباك اند (0.75)

  ThisWeekStaffStatisticsData({this.revenue, this.hoursWorked});

  factory ThisWeekStaffStatisticsData.fromJson(Map<String, dynamic> json) =>
      _$ThisWeekStaffStatisticsDataFromJson(json);
  Map<String, dynamic> toJson() => _$ThisWeekStaffStatisticsDataToJson(this);

  // 👇 دالة مساعدة — تحويل الرقم العشري لنص مفهوم
  String get formattedWorkedTime {
    final hoursValue = hoursWorked ?? 0;
    final totalMinutes = (hoursValue * 60)
        .round(); // 👈 التحويل هون: 0.75 × 60 = 45

    if (totalMinutes < 60) return '$totalMinutes دقيقة';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) return '$hours ساعة';
    return '$hours ساعة و$minutes دقيقة';
  }
}
