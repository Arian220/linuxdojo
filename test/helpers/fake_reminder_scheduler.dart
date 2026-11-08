import 'package:linuxdojo/features/notifications/data/reminder_scheduler.dart';

class FakeReminderScheduler implements ReminderScheduler {
  DateTime? lastScheduledAt;
  int scheduleCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> scheduleDaily(DateTime scheduledAt) async {
    scheduleCalls++;
    lastScheduledAt = scheduledAt;
  }

  @override
  Future<void> cancelDaily() async {
    cancelCalls++;
  }
}
