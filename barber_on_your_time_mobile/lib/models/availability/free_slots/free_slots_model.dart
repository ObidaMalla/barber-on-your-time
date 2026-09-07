import 'package:json_annotation/json_annotation.dart';

part 'free_slots_model.g.dart';

@JsonSerializable()
class FreeSlotsModel {
  bool? success;
  int? statusCode;
  String? message;
  List<FreeSlotDay>? data;

  FreeSlotsModel({this.success, this.statusCode, this.message, this.data});

  factory FreeSlotsModel.fromJson(Map<String, dynamic> json) =>
      _$FreeSlotsModelFromJson(json);
  Map<String, dynamic> toJson() => _$FreeSlotsModelToJson(this);
}

@JsonSerializable()
class FreeSlotDay {
  String? date;
  WorkingHours? workingHours;
  List<FreeWindow>? freeWindows;

  FreeSlotDay({this.date, this.workingHours, this.freeWindows});

  factory FreeSlotDay.fromJson(Map<String, dynamic> json) =>
      _$FreeSlotDayFromJson(json);
  Map<String, dynamic> toJson() => _$FreeSlotDayToJson(this);
}

@JsonSerializable()
class WorkingHours {
  String? startTime;
  String? endTime;

  WorkingHours({this.startTime, this.endTime});

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);
  Map<String, dynamic> toJson() => _$WorkingHoursToJson(this);
}

@JsonSerializable()
class FreeWindow {
  String? from;
  String? to;

  FreeWindow({this.from, this.to});

  factory FreeWindow.fromJson(Map<String, dynamic> json) =>
      _$FreeWindowFromJson(json);
  Map<String, dynamic> toJson() => _$FreeWindowToJson(this);
}
