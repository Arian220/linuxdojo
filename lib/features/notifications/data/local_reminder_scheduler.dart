import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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

    final location = await _localLocation();
    final now = tz.TZDateTime.now(location);
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

    await plugin.zonedSchedule(
      id: _notificationId,
      title: 'Time to practice Linux',
      body: 'Keep your streak alive with a quick LinuxDojo session.',
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
    await plugin.cancel(id: _notificationId);
  }

  Future<tz.Location> _localLocation() async {
    tz_data.initializeTimeZones();

    try {
      final info = await FlutterTimezone.getLocalTimezone();
      return tz.getLocation(info.identifier);
    } catch (_) {
      final offset = DateTime.now().timeZoneOffset;
      return tz.Location('local', [tz.minTime], [0], [
        tz.TimeZone(offset, isDst: false, abbreviation: 'LOCAL'),
      ]);
    }
  }
}

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return const LocalReminderScheduler();
});
