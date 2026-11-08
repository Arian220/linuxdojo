import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:linuxdojo/features/notifications/data/local_notification_plugin.dart';
import 'package:linuxdojo/features/notifications/data/reminder_scheduler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalReminderScheduler implements ReminderScheduler {
  const LocalReminderScheduler();

  static const _notificationId = 1001;
  static const _channelId = 'daily_reminder';

  @override
  Future<void> scheduleDaily(DateTime scheduledAt) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    await initializeLocalNotifications();

    final location = await _localLocation();
    final now = tz.TZDateTime.now(location);
    final target = reminderScheduleTarget(
      location: location,
      scheduledAt: scheduledAt,
      now: now,
    );

    await localNotificationsPlugin.zonedSchedule(
      id: _notificationId,
      title: 'Time to practice Linux',
      body: "Review Linux commands and make progress toward today's goal.",
      scheduledDate: target,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Daily reminder',
          channelDescription:
              'A smart daily reminder to review Linux commands.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Future<void> cancelDaily() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    await initializeLocalNotifications();
    await localNotificationsPlugin.cancel(id: _notificationId);
  }

  Future<tz.Location> _localLocation() async {
    tz_data.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    return tz.getLocation(info.identifier);
  }
}

tz.TZDateTime reminderScheduleTarget({
  required tz.Location location,
  required DateTime scheduledAt,
  required tz.TZDateTime now,
}) {
  var target = tz.TZDateTime(
    location,
    scheduledAt.year,
    scheduledAt.month,
    scheduledAt.day,
    scheduledAt.hour,
    scheduledAt.minute,
  );
  if (!target.isAfter(now)) {
    target = tz.TZDateTime(
      location,
      scheduledAt.year,
      scheduledAt.month,
      scheduledAt.day + 1,
      scheduledAt.hour,
      scheduledAt.minute,
    );
  }
  return target;
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return const LocalReminderScheduler();
});
