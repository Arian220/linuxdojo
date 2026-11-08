import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/features/notifications/data/local_reminder_scheduler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('keeps the reminder at the same local time across spring DST', () {
    final location = tz.getLocation('America/Los_Angeles');
    final now = tz.TZDateTime(location, 2026, 3, 7, 20);
    final target = reminderScheduleTarget(
      location: location,
      scheduledAt: DateTime(2026, 3, 7, 19),
      now: now,
    );

    expect(target, tz.TZDateTime(location, 2026, 3, 8, 19));
    expect(target.timeZoneOffset, const Duration(hours: -7));
  });

  test('keeps the reminder at the same local time across fall DST', () {
    final location = tz.getLocation('America/Los_Angeles');
    final now = tz.TZDateTime(location, 2026, 10, 31, 20);
    final target = reminderScheduleTarget(
      location: location,
      scheduledAt: DateTime(2026, 10, 31, 19),
      now: now,
    );

    expect(target, tz.TZDateTime(location, 2026, 11, 1, 19));
    expect(target.timeZoneOffset, const Duration(hours: -8));
  });
}
