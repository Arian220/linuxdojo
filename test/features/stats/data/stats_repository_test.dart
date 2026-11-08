import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/stats/data/stats_repository.dart';
import 'package:linuxdojo/features/study/data/review_repository.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late StatsRepository repository;
  late DateTime now;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    now = DateTime(2026, 3, 10, 12);
    repository = StatsRepository(
      database,
      SettingsRepository(database),
      () => now,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('reads sessions, mastered cards, and the daily goal', () async {
    await SettingsRepository(database)
        .set(SettingsRepository.dailyGoalKey, '5');
    await SessionRepository(database).recordSession(
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 10)),
      cardsReviewed: 8,
      correctAnswers: 7,
      multipleChoiceAnswered: 4,
      multipleChoiceCorrect: 3,
      bestMultipleChoiceStreak: 3,
    );

    final reviews = ReviewRepository(database);
    for (var index = 0; index < 3; index++) {
      await reviews.applyGrade(
        cardId: 1,
        grade: ReviewGrade.good,
        reviewedAt: now,
      );
    }

    final stats = await repository.getUserStats();

    expect(stats.totalSessions, 1);
    expect(stats.cardsReviewed, 8);
    expect(stats.correctAnswers, 7);
    expect(stats.multipleChoiceAnswered, 4);
    expect(stats.multipleChoiceCorrect, 3);
    expect(stats.bestMultipleChoiceStreak, 3);
    expect(stats.masteredCards, 1);
    expect(stats.totalCards, 8);
    expect(stats.dailyGoal, 5);
    expect(stats.cardsReviewedToday, 8);
    expect(stats.dailyGoalMet, isTrue);
    expect(stats.currentStreak, 1);
  });

  test('watches mastered and total card counts', () async {
    expect(await repository.watchMasteredCards().first, 0);
    expect(await repository.watchTotalCards().first, 8);

    final reviews = ReviewRepository(database);
    for (var index = 0; index < 3; index++) {
      await reviews.applyGrade(
        cardId: 1,
        grade: ReviewGrade.good,
        reviewedAt: now,
      );
    }

    expect(await repository.watchMasteredCards().first, 1);
  });
}
