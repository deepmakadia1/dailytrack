import 'package:dailytrack/core/notifications/notification_permission.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// [NotificationPermission] backed by `flutter_local_notifications`
/// (research R1: no extra permission package).
final class LocalNotificationPermission implements NotificationPermission {
  const new();

  @override
  Future<bool> request() async {
    try {
      final android = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return true;
      return await android.requestNotificationsPermission() ?? true;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> isGranted() async {
    try {
      final android = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android == null) return true;
      return await android.areNotificationsEnabled() ?? true;
    } on Object {
      return false;
    }
  }
}
