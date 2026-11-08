import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/theme/app_theme.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/stats/data/achievement_repository.dart';
import 'package:linuxdojo/features/stats/data/achievement_service.dart';
import 'package:linuxdojo/features/stats/data/stats_repository.dart';
import 'package:linuxdojo/features/stats/domain/achievement.dart';
import 'package:linuxdojo/features/stats/presentation/achievements_screen.dart';
import 'package:linuxdojo/features/stats/presentation/stats_screen.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late DateTime now;

  setUp(() async {
    database = createTestDatabase();
    now = DateTime(2026, 3, 10, 12);
    await SettingsRepository(database)
        .set(SettingsRepository.dailyGoalKey, '5');
    await SessionRepository(database).recordSession(
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 10)),
      cardsReviewed: 10,
      correctAnswers: 9,
    );
    await AchievementService(
      StatsRepository(database, SettingsRepository(database), () => now),
      AchievementRepository(database),
    ).sync();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('shows streak, weekly activity, and unlocked achievements', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          statsClockProvider.overrideWithValue(() => now),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const StatsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 day streak'), findsOneWidget);
    expect(find.text('10 / 5 cards today'), findsOneWidget);
    expect(find.text('Last 7 days'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Achievements'), 200);
    await tester.pumpAndSettle();

    expect(
      find.text('3 of ${achievementDefinitions.length} unlocked'),
      findsOneWidget,
    );

    await tester.tap(find.text('Achievements'));
    await tester.pumpAndSettle();

    expect(find.byType(AchievementsScreen), findsOneWidget);
    expect(
      find.text('3 of ${achievementDefinitions.length} unlocked'),
      findsOneWidget,
    );
    expect(find.text('Hello, World'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
