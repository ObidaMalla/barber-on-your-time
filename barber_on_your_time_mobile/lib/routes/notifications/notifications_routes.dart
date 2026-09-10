import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../core/constants/api_constants.dart';
import '../../models/notifications/notifications_model.dart';

part 'notifications_routes.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class NotificationsService {
  factory NotificationsService(Dio dio, {String baseUrl}) =
      _NotificationsService;

  @GET('/notifications')
  Future<NotificationsModel> getNotifications(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('/notifications/unread-count')
  Future<UnreadCountModel> getUnreadCount();

  @PATCH('/notifications/{id}/read')
  Future<DeleteNotificationModel> markAsRead(@Path('id') String id);
  @DELETE('/notifications/{id}')
  Future<DeleteNotificationModel> deleteNotification(@Path('id') String id);
}
