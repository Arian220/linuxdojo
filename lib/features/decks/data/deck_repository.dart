import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/models/review_thresholds.dart';
import 'package:linuxdojo/features/decks/domain/deck_summary.dart';

class DeckRepository {
  const DeckRepository(this._database);

  static const masteredRepetitions = ReviewThresholds.masteredRepetitions;

  final AppDatabase _database;

  Stream<List<Deck>> watchDecks() {
    final query = _database.select(_database.decks)
      ..orderBy([(deck) => OrderingTerm.asc(deck.id)]);
    return query.watch();
  }

  Future<List<Deck>> getDecks() {
    final query = _database.select(_database.decks)
      ..orderBy([(deck) => OrderingTerm.asc(deck.id)]);
    return query.get();
  }

  Future<Deck?> getDeck(int id) {
    final query = _database.select(_database.decks)
      ..where((deck) => deck.id.equals(id));
    return query.getSingleOrNull();
  }

  Stream<List<DeckSummary>> watchDeckSummaries() => _watchDeckSummaries();

  Stream<DeckSummary?> watchDeckSummary(int deckId) {
    return _watchDeckSummaries(deckId: deckId)
        .map((summaries) => summaries.isEmpty ? null : summaries.first);
  }

  Stream<List<CardEntry>> watchCardsForDeck(int deckId) {
    final query = _database.select(_database.cards)
      ..where((card) => card.deckId.equals(deckId))
      ..orderBy([(card) => OrderingTerm.asc(card.id)]);
    return query.watch();
  }

  Future<List<CardEntry>> getCardsForDeck(int deckId) {
    final query = _database.select(_database.cards)
      ..where((card) => card.deckId.equals(deckId))
      ..orderBy([(card) => OrderingTerm.asc(card.id)]);
    return query.get();
  }

  Future<int> countCardsForDeck(int deckId) async {
    final count = _database.cards.id.count();
    final query = _database.selectOnly(_database.cards)
      ..addColumns([count])
      ..where(_database.cards.deckId.equals(deckId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<List<DeckSummary>> _watchDeckSummaries({int? deckId}) {
    final totalCards = _database.cards.id.count();
    final masteredCards = CustomExpression<int>(
      'SUM(CASE WHEN reviews.repetitions >= $masteredRepetitions '
      'THEN 1 ELSE 0 END)',
    );

    final query =
        _database.select(_database.decks).join([
            leftOuterJoin(
              _database.cards,
              _database.cards.deckId.equalsExp(_database.decks.id),
            ),
            leftOuterJoin(
              _database.reviews,
              _database.reviews.cardId.equalsExp(_database.cards.id),
            ),
          ])
          ..addColumns([totalCards, masteredCards])
          ..groupBy([_database.decks.id])
          ..orderBy([OrderingTerm.asc(_database.decks.id)]);

    if (deckId != null) {
      query.where(_database.decks.id.equals(deckId));
    }

    return query.watch().map(
      (rows) => rows
          .map(
            (row) => DeckSummary(
              deck: row.readTable(_database.decks),
              totalCards: row.read(totalCards) ?? 0,
              masteredCards: row.read(masteredCards) ?? 0,
            ),
          )
          .toList(growable: false),
    );
  }
}

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepository(ref.watch(appDatabaseProvider));
});

final deckSummariesProvider = StreamProvider<List<DeckSummary>>((ref) {
  return ref.watch(deckRepositoryProvider).watchDeckSummaries();
});

final deckSummaryProvider = StreamProvider.family<DeckSummary?, int>((
  ref,
  deckId,
) {
  return ref.watch(deckRepositoryProvider).watchDeckSummary(deckId);
});

final deckCardsProvider = StreamProvider.family<List<CardEntry>, int>((
  ref,
  deckId,
) {
  return ref.watch(deckRepositoryProvider).watchCardsForDeck(deckId);
});
