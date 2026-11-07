import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/seed_source.dart';

class SeedResult {
  const SeedResult({required this.decksInserted, required this.cardsInserted});

  const SeedResult.empty() : decksInserted = 0, cardsInserted = 0;

  final int decksInserted;
  final int cardsInserted;

  bool get didSeed => decksInserted > 0;
}

class DatabaseSeeder {
  const DatabaseSeeder(this._source);

  final SeedSource _source;

  Future<SeedResult> seedIfEmpty(AppDatabase database) async {
    if (await _deckCount(database) > 0) {
      return const SeedResult.empty();
    }

    final decks = await _source.load();

    return database.transaction(() async {
      if (await _deckCount(database) > 0) {
        return const SeedResult.empty();
      }

      final now = DateTime.now();
      var cardsInserted = 0;

      for (final deck in decks) {
        await database
            .into(database.decks)
            .insert(
              DecksCompanion.insert(
                id: Value(deck.id),
                name: deck.name,
                description: deck.description,
                icon: deck.icon,
              ),
            );

        for (final card in deck.cards) {
          final cardId = await database
              .into(database.cards)
              .insert(
                CardsCompanion.insert(
                  deckId: deck.id,
                  prompt: card.prompt,
                  answer: card.answer,
                  example: card.example,
                  type: card.type,
                  difficultyTag: card.difficultyTag,
                  options: Value(
                    card.options == null ? null : jsonEncode(card.options),
                  ),
                ),
              );

          await database
              .into(database.reviews)
              .insert(
                ReviewsCompanion.insert(cardId: Value(cardId), nextReview: now),
              );
          cardsInserted++;
        }
      }

      return SeedResult(
        decksInserted: decks.length,
        cardsInserted: cardsInserted,
      );
    });
  }

  Future<int> _deckCount(AppDatabase database) {
    return database.decks.count().getSingle();
  }
}
