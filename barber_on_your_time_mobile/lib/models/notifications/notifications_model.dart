import 'package:json_annotation/json_annotation.dart';

part 'notifications_model.g.dart';

@JsonSerializable()
class NotificationsModel {
  bool? success;
  int? statusCode;
  String? message;
  NotificationsData? data;

  NotificationsModel({this.success, this.statusCode, this.message, this.data});

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsModelToJson(this);
}

@JsonSerializable()
class NotificationsData {
  List<NotificationItem>? notifications;
  PaginationModel? pagination;

  NotificationsData({this.notifications, this.pagination});

  factory NotificationsData.fromJson(Map<String, dynamic> json) =>
      _$NotificationsDataFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsDataToJson(this);
}

@JsonSerializable()
class NotificationItem {
  String? id;
  int? userId;
  String? type;
  String? title;
  String? message;
  dynamic data;
  bool? isRead;
  String? createdAt;

  NotificationItem({
    this.id,
    this.userId,
    this.type,
    this.title,
    this.message,
    this.data,
    this.isRead,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationItemToJson(this);
}

@JsonSerializable()
class PaginationModel {
  int? total;
  int? page;
  int? limit;
  int? totalPages;

  PaginationModel({this.total, this.page, this.limit, this.totalPages});

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      _$PaginationModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationModelToJson(this);
}

@JsonSerializable()
class UnreadCountModel {
  bool? success;
  int? statusCode;
  String? message;
  UnreadCountData? data;

  UnreadCountModel({this.success, this.statusCode, this.message, this.data});

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountModelFromJson(json);
  Map<String, dynamic> toJson() => _$UnreadCountModelToJson(this);
}

@JsonSerializable()
class UnreadCountData {
  int? unreadCount;

  UnreadCountData({this.unreadCount});

  factory UnreadCountData.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountDataFromJson(json);
  Map<String, dynamic> toJson() => _$UnreadCountDataToJson(this);
}

@JsonSerializable()
class DeleteNotificationModel {
  bool? success;
  int? statusCode;
  String? message;
  dynamic data;

  DeleteNotificationModel({
    this.success,
    this.statusCode,
    this.message,
    this.data,
  });

  factory DeleteNotificationModel.fromJson(Map<String, dynamic> json) =>
      _$DeleteNotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeleteNotificationModelToJson(this);
}
