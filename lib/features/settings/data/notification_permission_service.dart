import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/features/notifications/data/local_notification_plugin.dart';

abstract class NotificationPermissionService {
  Future<bool> requestPermission();

  Future<bool> hasPermission();

  Future<bool> openSettings();
}

class LocalNotificationPermissionService
    implements NotificationPermissionService {
  const LocalNotificationPermissionService();

  @override
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    await initializeLocalNotifications();
    if (Platform.isAndroid) {
      return await localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }

    return await localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  @override
  Future<bool> hasPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    await initializeLocalNotifications();
    if (Platform.isAndroid) {
      return await localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;
    }

    return await localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.checkPermissions()
            .then((permissions) => permissions?.isEnabled ?? false) ??
        false;
  }

  @override
  Future<bool> openSettings() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    await initializeLocalNotifications();
    if (Platform.isAndroid) {
      return await localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.openAppNotificationSettings() ??
          false;
    }

    return await localNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.openAppNotificationSettings() ??
        false;
  }
}

final notificationPermissionServiceProvider =
    Provider<NotificationPermissionService>(
      (ref) => const LocalNotificationPermissionService(),
    );

final notificationPermissionProvider = FutureProvider<bool>((ref) {
  return ref.watch(notificationPermissionServiceProvider).hasPermission();
});
