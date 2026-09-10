import '../../models/notifications/notifications_model.dart';
import '../../routes/notifications/notifications_routes.dart';
import '../apiExceptionHandler.dart';

class NotificationsRepository {
  final NotificationsService notificationsService;
  NotificationsRepository(this.notificationsService);

  Future<NotificationsModel> getNotifications({int page = 1, int limit = 10}) {
    return ApiExceptionHandler.handle<NotificationsModel>(
      () => notificationsService.getNotifications(page, limit),
      fallbackErrorMessage: 'فشل جلب الإشعارات 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<UnreadCountModel> getUnreadCount() {
    return ApiExceptionHandler.handle<UnreadCountModel>(
      () => notificationsService.getUnreadCount(),
      fallbackErrorMessage: 'فشل جلب عدد الإشعارات 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<DeleteNotificationModel> deleteNotification(String id) {
    return ApiExceptionHandler.handle<DeleteNotificationModel>(
      () => notificationsService.deleteNotification(id),
      fallbackErrorMessage: 'فشل حذف الإشعار 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }

  Future<DeleteNotificationModel> markAsRead(String id) {
    return ApiExceptionHandler.handle<DeleteNotificationModel>(
      () => notificationsService.markAsRead(id),
      fallbackErrorMessage: 'فشل تعليم الإشعار كمقروء 🧨',
      isSuccess: (r) => r.success == true,
      extractMessage: (r) => r.message,
    );
  }
}
