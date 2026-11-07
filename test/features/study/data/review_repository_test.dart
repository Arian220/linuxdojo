import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/features/study/data/review_repository.dart';
import 'package:linuxdojo/features/study/data/study_repository.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late ReviewRepository repository;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    repository = ReviewRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('persists a Good grade and next review date', () async {
    final reviewedAt = DateTime(2026, 3, 1, 10);

    final next = await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.good,
      reviewedAt: reviewedAt,
    );

    expect(next.interval, 1);
    expect(next.repetitions, 1);

    final stored = await repository.getState(1);
    expect(stored, isNotNull);
    expect(stored!.interval, 1);
    expect(stored.easeFactor, 2.5);
    expect(stored.repetitions, 1);
    expect(stored.nextReview, reviewedAt.add(const Duration(days: 1)));
    expect(stored.lastReview, reviewedAt);
  });

  test('second Good persists a six day interval', () async {
    final reviewedAt = DateTime(2026, 3, 1, 10);

    await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.good,
      reviewedAt: reviewedAt,
    );
    await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.good,
      reviewedAt: reviewedAt,
    );

    final stored = await repository.getState(1);
    expect(stored!.interval, 6);
    expect(stored.repetitions, 2);
  });

  test('Again resets progress after successful reviews', () async {
    final reviewedAt = DateTime(2026, 3, 1, 10);

    await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.good,
      reviewedAt: reviewedAt,
    );
    await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.good,
      reviewedAt: reviewedAt,
    );
    await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.again,
      reviewedAt: reviewedAt,
    );

    final stored = await repository.getState(1);
    expect(stored!.interval, 1);
    expect(stored.repetitions, 0);
    expect(stored.easeFactor, closeTo(1.7, 1e-9));
  });

  test('grading a due card removes it from the due list', () async {
    final studyRepository = StudyRepository(database);
    expect(await studyRepository.countDueCards(), 3);

    await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.good,
      reviewedAt: DateTime.now(),
    );

    expect(await studyRepository.countDueCards(), 2);
  });

  test('multiple choice mapping auto-grades wrong answers as Again', () async {
    final reviewedAt = DateTime(2026, 3, 1, 10);

    await repository.applyGrade(
      cardId: 1,
      grade: ReviewGrade.fromMultipleChoice(correct: false),
      reviewedAt: reviewedAt,
    );

    final stored = await repository.getState(1);
    expect(stored!.repetitions, 0);
    expect(stored.interval, 1);
    expect(stored.easeFactor, closeTo(1.7, 1e-9));
  });
}
