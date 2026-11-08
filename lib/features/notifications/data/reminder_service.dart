import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/features/notifications/data/local_reminder_scheduler.dart';
import 'package:linuxdojo/features/notifications/data/reminder_scheduler.dart';
import 'package:linuxdojo/features/notifications/domain/smart_reminder.dart';
import 'package:linuxdojo/features/settings/data/notification_permission_service.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/stats/domain/stats_calculator.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';

class ReminderService {
  const ReminderService({
    required this.settings,
    required this.sessions,
    required this.scheduler,
    required this.permissionService,
    this.onSyncError,
    this.reminder = const SmartReminder(),
  });

  final SettingsRepository settings;
  final SessionRepository sessions;
  final ReminderScheduler scheduler;
  final NotificationPermissionService permissionService;
  final void Function(Object? error)? onSyncError;
  final SmartReminder reminder;

  Future<ReminderPlan?> sync({DateTime? now, Random? random}) async {
    try {
      final appSettings = await settings.getAppSettings();
      await scheduler.cancelDaily();

      if (!appSettings.remindersEnabled) {
        onSyncError?.call(null);
        return null;
      }

      if (!await permissionService.hasPermission()) {
        throw const ReminderPermissionDeniedException();
      }

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
        dailyGoalMetToday: stats.cardsReviewedToday >= appSettings.dailyGoal,
        now: current,
        random: random ?? Random(),
      );

      await scheduler.scheduleDaily(plan.scheduledAt);
      onSyncError?.call(null);
      return plan;
    } catch (error, stackTrace) {
      onSyncError?.call(error);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

class ReminderPermissionDeniedException implements Exception {
  const ReminderPermissionDeniedException();
}

class ReminderSyncStatus extends Notifier<String?> {
  @override
  String? build() => null;

  void report(Object? error) {
    state = switch (error) {
      null => null,
      ReminderPermissionDeniedException() => 'Notifications are blocked. Enable them in system settings to receive reminders.',
      _ => 'Could not schedule your reminder. Open Settings to try again.',
    };
  }
}

final reminderSyncStatusProvider =
    NotifierProvider<ReminderSyncStatus, String?>(ReminderSyncStatus.new);

final reminderServiceProvider = Provider<ReminderService>((ref) {
  return ReminderService(
    settings: ref.watch(settingsRepositoryProvider),
    sessions: ref.watch(sessionRepositoryProvider),
    scheduler: ref.watch(reminderSchedulerProvider),
    permissionService: ref.watch(notificationPermissionServiceProvider),
    onSyncError: (error) =>
        ref.read(reminderSyncStatusProvider.notifier).report(error),
  );
});
