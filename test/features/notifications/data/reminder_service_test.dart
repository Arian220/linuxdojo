import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/features/notifications/data/reminder_service.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';

import '../../../helpers/fake_notification_permission_service.dart';
import '../../../helpers/fake_reminder_scheduler.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository settings;
  late SessionRepository sessions;
  late FakeReminderScheduler scheduler;
  late FakeNotificationPermissionService permissions;
  late ReminderService service;

  setUp(() {
    database = createTestDatabase();
    settings = SettingsRepository(database);
    sessions = SessionRepository(database);
    scheduler = FakeReminderScheduler();
    permissions = FakeNotificationPermissionService();
    service = ReminderService(
      settings: settings,
      sessions: sessions,
      scheduler: scheduler,
      permissionService: permissions,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('cancels notifications when reminders are disabled', () async {
    final plan = await service.sync(
      now: DateTime(2026, 11, 7, 12),
      random: Random(1),
    );

    expect(plan, isNull);
    expect(scheduler.cancelCalls, 1);
    expect(scheduler.scheduleCalls, 0);
  });

  test('schedules a smart daily time when reminders are enabled', () async {
    await settings.setRemindersEnabled(true);
    await settings.setDailyGoal(10);
    await sessions.recordSession(
      startedAt: DateTime(2026, 11, 6, 19),
      endedAt: DateTime(2026, 11, 6, 19, 12),
      cardsReviewed: 10,
      correctAnswers: 8,
    );

    final now = DateTime(2026, 11, 7, 12);
    final plan = await service.sync(now: now, random: Random(3));

    expect(plan, isNotNull);
    expect(scheduler.cancelCalls, 1);
    expect(scheduler.scheduleCalls, 1);
    expect(scheduler.lastScheduledAt, plan!.scheduledAt);
    expect(scheduler.lastScheduledAt!.isAfter(now), isTrue);
    expect(scheduler.lastScheduledAt!.hour, inInclusiveRange(18, 19));
  });

  test('uses the daily goal when computing the schedule', () async {
    await settings.setRemindersEnabled(true);
    await sessions.recordSession(
      startedAt: DateTime(2026, 11, 6, 19),
      endedAt: DateTime(2026, 11, 6, 19, 10),
      cardsReviewed: 30,
      correctAnswers: 24,
    );

    final now = DateTime(2026, 11, 7, 12);
    await settings.setDailyGoal(10);
    final light = await service.sync(now: now, random: Random(6));

    await settings.setDailyGoal(30);
    final heavy = await service.sync(now: now, random: Random(6));

    expect(
      heavy!.scheduledAt.difference(light!.scheduledAt),
      const Duration(minutes: -30),
    );
  });

  test("schedules for tomorrow when today's goal has been met", () async {
    await settings.setRemindersEnabled(true);
    await settings.setDailyGoal(10);
    await sessions.recordSession(
      startedAt: DateTime(2026, 11, 7, 9),
      endedAt: DateTime(2026, 11, 7, 10),
      cardsReviewed: 10,
      correctAnswers: 9,
    );

    final now = DateTime(2026, 11, 7, 12);
    final plan = await service.sync(now: now, random: Random(4));

    expect(plan!.scheduledAt.day, 8);
    expect(plan.scheduledAt.isAfter(now), isTrue);
    expect(scheduler.lastScheduledAt, plan.scheduledAt);
  });

  test('cancels the reminder and reports revoked permission', () async {
    await settings.setRemindersEnabled(true);
    permissions = FakeNotificationPermissionService(granted: false);
    service = ReminderService(
      settings: settings,
      sessions: sessions,
      scheduler: scheduler,
      permissionService: permissions,
    );

    await expectLater(
      service.sync(now: DateTime(2026, 11, 7, 12)),
      throwsA(isA<ReminderPermissionDeniedException>()),
    );

    expect(scheduler.cancelCalls, 1);
    expect(scheduler.scheduleCalls, 0);
  });
}
