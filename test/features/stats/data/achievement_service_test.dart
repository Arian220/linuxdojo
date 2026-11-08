import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/stats/data/achievement_repository.dart';
import 'package:linuxdojo/features/stats/data/achievement_service.dart';
import 'package:linuxdojo/features/stats/data/stats_repository.dart';
import 'package:linuxdojo/features/stats/domain/achievement.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late AchievementRepository achievements;
  late AchievementService service;
  late DateTime now;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    now = DateTime(2026, 3, 10, 12);
    achievements = AchievementRepository(database);
    service = AchievementService(
      StatsRepository(database, SettingsRepository(database), () => now),
      achievements,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('defines at least 30 unique achievements', () {
    expect(achievementDefinitions.length, greaterThanOrEqualTo(30));
    expect(
      achievementDefinitions.map((definition) => definition.id).toSet(),
      hasLength(achievementDefinitions.length),
    );
  });

  test('unlocks achievements once conditions are met', () async {
    await SessionRepository(database).recordSession(
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 10)),
      cardsReviewed: 8,
      correctAnswers: 8,
      multipleChoiceAnswered: 4,
      multipleChoiceCorrect: 4,
      bestMultipleChoiceStreak: 4,
    );

    final statuses = await service.sync();
    final byId = {for (final status in statuses) status.definition.id: status};

    expect(byId['first_session']!.isUnlocked, isTrue);
    expect(byId['mc_streak_5']!.isUnlocked, isFalse);

    final firstUnlockedAt = byId['first_session']!.unlockedAt;
    final second = await service.sync();
    final secondFirstSession = second.firstWhere(
      (status) => status.definition.id == 'first_session',
    );

    expect(secondFirstSession.unlockedAt, firstUnlockedAt);
    expect(await achievements.getAchievements(), hasLength(1));
  });

  test('unlocks multiple-choice streak achievements', () async {
    await SessionRepository(database).recordSession(
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 10)),
      cardsReviewed: 6,
      correctAnswers: 5,
      multipleChoiceAnswered: 5,
      multipleChoiceCorrect: 5,
      bestMultipleChoiceStreak: 5,
    );

    final statuses = await service.sync();
    final byId = {for (final status in statuses) status.definition.id: status};

    expect(byId['mc_streak_5']!.isUnlocked, isTrue);
    expect(byId['mc_correct_10']!.isUnlocked, isFalse);
  });
}
