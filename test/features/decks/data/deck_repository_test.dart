import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/features/decks/data/deck_repository.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late DeckRepository repository;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    repository = DeckRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('returns decks ordered by id', () async {
    final decks = await repository.getDecks();

    expect(decks.map((deck) => deck.name), ['Basics', 'Permissions']);
  });

  test('returns a single deck by id', () async {
    final deck = await repository.getDeck(2);

    expect(deck?.name, 'Permissions');
    expect(await repository.getDeck(99), isNull);
  });

  test('returns cards for a deck in id order', () async {
    final cards = await repository.getCardsForDeck(1);

    expect(cards, hasLength(2));
    expect(cards.first.prompt, contains('pwd'));
    expect(await repository.countCardsForDeck(1), 2);
    expect(await repository.countCardsForDeck(2), 1);
  });

  test('deleting a deck cascades to its cards and reviews', () async {
    final query = database.delete(database.decks)
      ..where((deck) => deck.id.equals(1));

    await query.go();

    expect(await database.cards.count().getSingle(), 1);
    expect(await database.reviews.count().getSingle(), 1);
  });
}
