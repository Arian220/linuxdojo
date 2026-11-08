abstract class ReminderScheduler {
  Future<void> scheduleDaily(DateTime scheduledAt);

  Future<void> cancelDaily();
}
