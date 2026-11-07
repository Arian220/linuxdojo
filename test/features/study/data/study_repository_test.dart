import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/features/study/data/study_repository.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late StudyRepository repository;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    repository = StudyRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('all seeded cards are due initially', () async {
    final cards = await repository.getDueCards();

    expect(cards, hasLength(8));
    expect(await repository.countDueCards(), 8);
  });

  test('excludes cards scheduled in the future', () async {
    final future = DateTime.now().add(const Duration(days: 3));
    await database
        .into(database.reviews)
        .insertOnConflictUpdate(
          ReviewsCompanion(cardId: const Value(1), nextReview: Value(future)),
        );

    final cards = await repository.getDueCards();

    expect(cards, hasLength(7));
    expect(cards.map((card) => card.id), isNot(contains(1)));
    expect(await repository.countDueCards(), 7);
  });

  test('returns the review state for a card', () async {
    final review = await repository.getReview(1);

    expect(review, isNotNull);
    expect(review!.cardId, 1);
    expect(review.easeFactor, 2.5);
    expect(await repository.getReview(99), isNull);
  });
}
