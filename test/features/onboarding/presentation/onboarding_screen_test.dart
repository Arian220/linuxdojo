import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/app/app.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/features/notifications/data/local_reminder_scheduler.dart';
import 'package:linuxdojo/features/settings/data/notification_permission_service.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/settings/domain/experience_level.dart';

import '../../../helpers/fake_notification_permission_service.dart';
import '../../../helpers/fake_reminder_scheduler.dart';
import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late FakeNotificationPermissionService notifications;
  late FakeReminderScheduler scheduler;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    notifications = FakeNotificationPermissionService();
    scheduler = FakeReminderScheduler();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('completes onboarding and persists preferences', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          notificationPermissionServiceProvider.overrideWithValue(
            notifications,
          ),
          reminderSchedulerProvider.overrideWithValue(scheduler),
        ],
        child: const LinuxDojoApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Choose your level'), findsOneWidget);
    expect(find.text('Step 1 of 4'), findsOneWidget);

    await tester.tap(find.text('Intermediate'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Set a daily goal'), findsOneWidget);
    await tester.tap(find.text('20 cards'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Stay on track'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(notifications.calls, 1);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isTrue,
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('You’re all set'), findsOneWidget);
    await tester.tap(find.text('Start studying'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);

    final settings = await SettingsRepository(database).getAppSettings();
    expect(settings.experienceLevel, ExperienceLevel.intermediate);
    expect(settings.dailyGoal, 20);
    expect(settings.remindersEnabled, isTrue);
    expect(settings.onboardingCompleted, isTrue);
    expect(scheduler.scheduleCalls, 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
