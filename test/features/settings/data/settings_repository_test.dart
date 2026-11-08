import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/settings/domain/experience_level.dart';
import 'package:linuxdojo/features/settings/domain/settings_keys.dart';
import 'package:linuxdojo/features/stats/data/achievement_repository.dart';
import 'package:linuxdojo/features/study/data/review_repository.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository repository;

  setUp(() {
    database = createTestDatabase();
    repository = SettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('stores, overwrites, and removes values', () async {
    expect(await repository.get('daily_goal'), isNull);

    await repository.set('daily_goal', '20');
    expect(await repository.get('daily_goal'), '20');

    await repository.set('daily_goal', '30');
    expect(await repository.get('daily_goal'), '30');

    await repository.remove('daily_goal');
    expect(await repository.get('daily_goal'), isNull);
  });

  test('returns all settings as a map', () async {
    await repository.set('experience_level', 'beginner');
    await repository.set('daily_goal', '10');

    expect(await repository.getAll(), {
      'experience_level': 'beginner',
      'daily_goal': '10',
    });
  });

  test('reads the daily goal with a safe fallback', () async {
    expect(
      await repository.getDailyGoal(),
      SettingsRepository.defaultDailyGoal,
    );

    await repository.set(SettingsRepository.dailyGoalKey, '20');
    expect(await repository.getDailyGoal(), 20);

    await repository.set(SettingsRepository.dailyGoalKey, 'not-a-number');
    expect(
      await repository.getDailyGoal(),
      SettingsRepository.defaultDailyGoal,
    );

    await repository.set(SettingsRepository.dailyGoalKey, '0');
    expect(
      await repository.getDailyGoal(),
      SettingsRepository.defaultDailyGoal,
    );
  });

  test('reads defaults and persists onboarding preferences', () async {
    final defaults = await repository.getAppSettings();

    expect(defaults.experienceLevel, ExperienceLevel.beginner);
    expect(defaults.dailyGoal, SettingsRepository.defaultDailyGoal);
    expect(defaults.remindersEnabled, isFalse);
    expect(defaults.onboardingCompleted, isFalse);

    await repository.setExperienceLevel(ExperienceLevel.advanced);
    await repository.setDailyGoal(30);
    await repository.setRemindersEnabled(true);
    await repository.setOnboardingComplete();

    final settings = await repository.getAppSettings();
    expect(settings.experienceLevel, ExperienceLevel.advanced);
    expect(settings.dailyGoal, 30);
    expect(settings.remindersEnabled, isTrue);
    expect(settings.onboardingCompleted, isTrue);
    expect(settings.experienceLevel, ExperienceLevel.fromValue('advanced'));
  });

  test('falls back to beginner for an unknown level', () async {
    await repository.set(SettingsKeys.experienceLevel, 'unknown');

    expect(
      (await repository.getAppSettings()).experienceLevel,
      ExperienceLevel.beginner,
    );
  });

  test('reset progress clears study data but keeps preferences', () async {
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    final now = DateTime(2026, 3, 10, 12);
    await repository.setDailyGoal(20);
    await repository.setExperienceLevel(ExperienceLevel.intermediate);
    await SessionRepository(database).recordSession(
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 10)),
      cardsReviewed: 4,
      correctAnswers: 3,
    );
    await ReviewRepository(database)
        .applyGrade(cardId: 1, grade: ReviewGrade.good, reviewedAt: now);
    await AchievementRepository(database).unlock('first_session', at: now);

    await repository.resetProgress();

    expect(await SessionRepository(database).getSessions(), isEmpty);
    expect(await AchievementRepository(database).getAchievements(), isEmpty);
    expect(await ReviewRepository(database).getState(1), isNull);

    final settings = await repository.getAppSettings();
    expect(settings.dailyGoal, 20);
    expect(settings.experienceLevel, ExperienceLevel.intermediate);
    expect(settings.onboardingCompleted, isFalse);
  });
}
