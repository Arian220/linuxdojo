import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';

import '../../helpers/fake_seed_source.dart';
import '../../helpers/sample_seed_data.dart';
import '../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late DatabaseSeeder seeder;

  setUp(() {
    database = createTestDatabase();
    seeder = const DatabaseSeeder(FakeSeedSource(sampleDecks));
  });

  tearDown(() async {
    await database.close();
  });

  test('seeds decks, cards, and initial review rows', () async {
    final result = await seeder.seedIfEmpty(database);

    expect(result.didSeed, isTrue);
    expect(result.decksInserted, 2);
    expect(result.cardsInserted, 8);
    expect(await database.decks.count().getSingle(), 2);
    expect(await database.cards.count().getSingle(), 8);
    expect(await database.reviews.count().getSingle(), 8);

    final reviews = await database.select(database.reviews).get();
    for (final review in reviews) {
      expect(review.interval, 0);
      expect(review.easeFactor, 2.5);
      expect(review.repetitions, 0);
      expect(review.lastReview, isNull);
      expect(review.nextReview.isAfter(DateTime.now()), isFalse);
    }
  });

  test('does not seed twice', () async {
    await seeder.seedIfEmpty(database);

    final second = await seeder.seedIfEmpty(database);

    expect(second.didSeed, isFalse);
    expect(second.decksInserted, 0);
    expect(second.cardsInserted, 0);
    expect(await database.decks.count().getSingle(), 2);
    expect(await database.cards.count().getSingle(), 8);
  });

  test('persists card type, difficulty, and options', () async {
    await seeder.seedIfEmpty(database);

    final query = database.select(database.cards)
      ..orderBy([(card) => OrderingTerm.asc(card.id)]);
    final cards = await query.get();

    expect(cards[0].type, CardType.flip);
    expect(cards[0].difficultyTag, DifficultyTag.novice);
    expect(cards[0].options, isNull);

    expect(cards[1].type, CardType.multipleChoice);
    expect(cards[1].options, '["ls","cd","pwd"]');
  });
}
