import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:linuxdojo/features/notifications/domain/reminder_intent.dart';

final localNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void>? _initialization;
bool _launchDetailsChecked = false;

Future<void> initializeLocalNotifications() async {
  final pending = _initialization;
  if (pending != null) {
    await pending;
    return;
  }

  final initialization = _initialize();
  _initialization = initialization;
  try {
    await initialization;
  } catch (_) {
    _initialization = null;
    rethrow;
  }
}

Future<void> _initialize() async {
  await localNotificationsPlugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: (_) => ReminderIntent.openStudy(),
  );

  if (_launchDetailsChecked) return;
  final launchDetails = await localNotificationsPlugin
      .getNotificationAppLaunchDetails();
  _launchDetailsChecked = true;
  if (launchDetails?.didNotificationLaunchApp ?? false) {
    ReminderIntent.openStudy();
  }
}
