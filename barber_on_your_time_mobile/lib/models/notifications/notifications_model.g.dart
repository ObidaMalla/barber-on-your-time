// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsModel _$NotificationsModelFromJson(Map<String, dynamic> json) =>
    NotificationsModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : NotificationsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationsModelToJson(NotificationsModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

NotificationsData _$NotificationsDataFromJson(Map<String, dynamic> json) =>
    NotificationsData(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] == null
          ? null
          : PaginationModel.fromJson(
              json['pagination'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$NotificationsDataToJson(NotificationsData instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'pagination': instance.pagination,
    };

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    NotificationItem(
      id: json['id'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      type: json['type'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      data: json['data'],
      isRead: json['isRead'] as bool?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$NotificationItemToJson(NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'title': instance.title,
      'message': instance.message,
      'data': instance.data,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt,
    };

PaginationModel _$PaginationModelFromJson(Map<String, dynamic> json) =>
    PaginationModel(
      total: (json['total'] as num?)?.toInt(),
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaginationModelToJson(PaginationModel instance) =>
    <String, dynamic>{
      'total': instance.total,
      'page': instance.page,
      'limit': instance.limit,
      'totalPages': instance.totalPages,
    };

UnreadCountModel _$UnreadCountModelFromJson(Map<String, dynamic> json) =>
    UnreadCountModel(
      success: json['success'] as bool?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
      message: json['message'] as String?,
      data: json['data'] == null
          ? null
          : UnreadCountData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UnreadCountModelToJson(UnreadCountModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'statusCode': instance.statusCode,
      'message': instance.message,
      'data': instance.data,
    };

UnreadCountData _$UnreadCountDataFromJson(Map<String, dynamic> json) =>
    UnreadCountData(unreadCount: (json['unreadCount'] as num?)?.toInt());

Map<String, dynamic> _$UnreadCountDataToJson(UnreadCountData instance) =>
    <String, dynamic>{'unreadCount': instance.unreadCount};

DeleteNotificationModel _$DeleteNotificationModelFromJson(
  Map<String, dynamic> json,
) => DeleteNotificationModel(
  success: json['success'] as bool?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  message: json['message'] as String?,
  data: json['data'],
);

Map<String, dynamic> _$DeleteNotificationModelToJson(
  DeleteNotificationModel instance,
) => <String, dynamic>{
  'success': instance.success,
  'statusCode': instance.statusCode,
  'message': instance.message,
  'data': instance.data,
};
