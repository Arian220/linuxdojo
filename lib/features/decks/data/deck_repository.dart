import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';

class DeckRepository {
  const DeckRepository(this._database);

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
}

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  return DeckRepository(ref.watch(appDatabaseProvider));
});
