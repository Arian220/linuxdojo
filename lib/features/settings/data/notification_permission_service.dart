import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NotificationPermissionService {
  Future<bool> requestPermission();
}

class LocalNotificationPermissionService
    implements NotificationPermissionService {
  const LocalNotificationPermissionService();

  @override
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;

    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      if (Platform.isAndroid) {
        return await plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      }

      return await plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } catch (_) {
      return false;
    }
  }
}

final notificationPermissionServiceProvider =
    Provider<NotificationPermissionService>(
      (ref) => const LocalNotificationPermissionService(),
    );
