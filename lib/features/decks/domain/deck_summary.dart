import 'package:linuxdojo/core/database/app_database.dart';

class DeckSummary {
  const DeckSummary({
    required this.deck,
    required this.totalCards,
    required this.masteredCards,
  });

  final Deck deck;
  final int totalCards;
  final int masteredCards;

  double get progress => totalCards == 0 ? 0 : masteredCards / totalCards;
}
