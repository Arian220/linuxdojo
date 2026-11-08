import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/core/theme/app_theme.dart';
import 'package:linuxdojo/features/notifications/data/local_reminder_scheduler.dart';
import 'package:linuxdojo/features/settings/data/notification_permission_service.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/settings/domain/experience_level.dart';
import 'package:linuxdojo/features/settings/presentation/settings_screen.dart';
import 'package:linuxdojo/features/stats/data/achievement_repository.dart';
import 'package:linuxdojo/features/study/data/review_repository.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';

import '../../../helpers/fake_notification_permission_service.dart';
import '../../../helpers/fake_reminder_scheduler.dart';
import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository settings;

  setUp(() async {
    database = createTestDatabase();
    settings = SettingsRepository(database);
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
  });

  tearDown(() async {
    await database.close();
  });

  Widget buildSettings({
    FakeNotificationPermissionService? notifications,
    FakeReminderScheduler? scheduler,
  }) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        notificationPermissionServiceProvider.overrideWithValue(
          notifications ?? FakeNotificationPermissionService(),
        ),
        reminderSchedulerProvider.overrideWithValue(
          scheduler ?? FakeReminderScheduler(),
        ),
      ],
      child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
    );
  }

  testWidgets('updates experience level and daily goal', (tester) async {
    await tester.pumpWidget(buildSettings());
    await tester.pumpAndSettle();

    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('10 cards per day'), findsOneWidget);

    await tester.tap(find.text('Experience level'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced'));
    await tester.pumpAndSettle();

    expect(find.text('Advanced'), findsOneWidget);
    expect(
      (await settings.getAppSettings()).experienceLevel,
      ExperienceLevel.advanced,
    );

    await tester.tap(find.text('Daily goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('30 cards per day'));
    await tester.pumpAndSettle();

    expect(find.text('30 cards per day'), findsOneWidget);
    expect(await settings.getDailyGoal(), 30);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('enables reminders after permission is granted', (tester) async {
    final notifications = FakeNotificationPermissionService();
    final scheduler = FakeReminderScheduler();
    await tester.pumpWidget(
      buildSettings(notifications: notifications, scheduler: scheduler),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(notifications.calls, 1);
    expect((await settings.getAppSettings()).remindersEnabled, isTrue);
    expect(scheduler.scheduleCalls, 1);
    expect(scheduler.lastScheduledAt, isNotNull);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('keeps reminders off when permission is denied', (tester) async {
    final notifications = FakeNotificationPermissionService(granted: false);
    await tester.pumpWidget(buildSettings(notifications: notifications));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pump();

    expect(notifications.calls, 1);
    expect((await settings.getAppSettings()).remindersEnabled, isFalse);
    expect(
      find.text('Notification permission is required for reminders.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('cancels scheduled reminders when disabled', (tester) async {
    await settings.setRemindersEnabled(true);
    final scheduler = FakeReminderScheduler();

    await tester.pumpWidget(buildSettings(scheduler: scheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(find.text('Turn off reminders?'), findsOneWidget);
    expect((await settings.getAppSettings()).remindersEnabled, isTrue);
    expect(scheduler.cancelCalls, 0);

    await tester.tap(find.text('Turn off'));
    await tester.pumpAndSettle();

    expect((await settings.getAppSettings()).remindersEnabled, isFalse);
    expect(scheduler.cancelCalls, 1);
    expect(scheduler.scheduleCalls, 0);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('keeps reminders enabled when disabling is canceled', (
    tester,
  ) async {
    await settings.setRemindersEnabled(true);
    final scheduler = FakeReminderScheduler();

    await tester.pumpWidget(buildSettings(scheduler: scheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect((await settings.getAppSettings()).remindersEnabled, isTrue);
    expect(scheduler.cancelCalls, 0);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('reschedules reminders after the daily goal changes', (
    tester,
  ) async {
    await settings.setRemindersEnabled(true);
    final scheduler = FakeReminderScheduler();
    await tester.pumpWidget(buildSettings(scheduler: scheduler));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily goal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('20 cards per day'));
    await tester.pumpAndSettle();

    expect(await settings.getDailyGoal(), 20);
    expect(scheduler.scheduleCalls, 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets(
    'offers system settings when notification permission is revoked',
    (tester) async {
      await settings.setRemindersEnabled(true);
      final notifications = FakeNotificationPermissionService(granted: false);
      await tester.pumpWidget(buildSettings(notifications: notifications));
      await tester.pumpAndSettle();

      expect(
        find.text('Notifications are blocked by the system.'),
        findsOneWidget,
      );
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.text('Open notification settings'));
      await tester.pumpAndSettle();

      expect(notifications.settingsCalls, 1);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );

  testWidgets('resets study data after confirmation', (tester) async {
    final now = DateTime(2026, 3, 10, 12);
    await settings.setDailyGoal(20);
    await settings.setOnboardingComplete();
    await SessionRepository(database).recordSession(
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 10)),
      cardsReviewed: 4,
      correctAnswers: 3,
    );
    await ReviewRepository(database)
        .applyGrade(cardId: 1, grade: ReviewGrade.good, reviewedAt: now);
    await AchievementRepository(database).unlock('first_session', at: now);

    await tester.pumpWidget(buildSettings());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Reset progress'), 200);
    await tester.tap(find.text('Reset progress'));
    await tester.pumpAndSettle();

    expect(find.text('Reset progress?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await tester.pumpAndSettle();

    expect(await SessionRepository(database).getSessions(), isEmpty);
    expect(await AchievementRepository(database).getAchievements(), isEmpty);
    expect(await ReviewRepository(database).getState(1), isNull);

    final updated = await settings.getAppSettings();
    expect(updated.dailyGoal, 20);
    expect(updated.onboardingCompleted, isTrue);
    expect(find.text('Progress reset.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('shows the MIT license', (tester) async {
    await tester.pumpWidget(buildSettings());
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('MIT License'), 200);
    await tester.tap(find.text('MIT License'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Permission is hereby granted'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
