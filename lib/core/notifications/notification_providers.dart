import 'package:dailytrack/core/notifications/local_notification_permission.dart';
import 'package:dailytrack/core/notifications/notification_permission.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/notifications/time_zone_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationPermission notificationPermission(Ref ref) =>
    const LocalNotificationPermission();

/// Local notifications (research R15). `production_overrides.dart` binds
/// `LocalNotificationService`; tests bind `FakeNotificationService`.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) =>
    throw UnimplementedError('notificationServiceProvider must be overridden');

/// The device time zone for scheduled notifications (feature 005 R1).
@Riverpod(keepAlive: true)
TimeZoneSource timeZoneSource(Ref ref) => const MethodChannelTimeZoneSource();
