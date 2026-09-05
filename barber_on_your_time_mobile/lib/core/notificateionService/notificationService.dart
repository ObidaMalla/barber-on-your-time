import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // يستدعى مرة وحدة بس، من main.dart
  static Future<void> initialize() async {
    // إعداد الإشعارات المحلية (أندرويد)
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // إنشاء قناة إشعارات (مطلوب لأندرويد 8+)
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'إشعارات مهمة', // اسم القناة يلي بيظهر بإعدادات النظام
      importance: Importance.high,
    );
    // ✅ السطر الصحيح:
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 👇 الجزء الأهم — الاستماع للإشعارات وقت التطبيق مفتوح (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'إشعارات مهمة',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  static Future<String?> getFcmToken() async {
    await FirebaseMessaging.instance.requestPermission();
    return FirebaseMessaging.instance.getToken();
  }
}
