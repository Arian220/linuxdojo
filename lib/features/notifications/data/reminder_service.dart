import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/features/notifications/data/local_reminder_scheduler.dart';
import 'package:linuxdojo/features/notifications/data/reminder_scheduler.dart';
import 'package:linuxdojo/features/notifications/domain/smart_reminder.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/stats/domain/stats_calculator.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';

class ReminderService {
  const ReminderService({
    required this.settings,
    required this.sessions,
    required this.scheduler,
    this.reminder = const SmartReminder(),
  });

  final SettingsRepository settings;
  final SessionRepository sessions;
  final ReminderScheduler scheduler;
  final SmartReminder reminder;

  Future<ReminderPlan?> sync({DateTime? now, Random? random}) async {
    final appSettings = await settings.getAppSettings();
    await scheduler.cancelDaily();

    if (!appSettings.remindersEnabled) return null;

    final current = now ?? DateTime.now();
    final sessionLogs = await sessions.getAllSessions();
    final stats = StatsCalculator.buildUserStats(
      sessions: sessionLogs,
      dailyGoal: appSettings.dailyGoal,
      masteredCards: 0,
      totalCards: 0,
      now: current,
    );
    final plan = reminder.nextReminder(
      sessions: [
        for (final session in sessionLogs)
          ReminderSession(
            startedAt: session.startedAt,
            endedAt: session.endedAt,
          ),
      ],
      currentStreak: stats.currentStreak,
      dailyGoal: appSettings.dailyGoal,
      now: current,
      random: random ?? Random(),
    );

    await scheduler.scheduleDaily(plan.scheduledAt);
    return plan;
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(
    settings: ref.watch(settingsRepositoryProvider),
    sessions: ref.watch(sessionRepositoryProvider),
    scheduler: ref.watch(reminderSchedulerProvider),
  );
});
