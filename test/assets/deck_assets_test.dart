import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/seed/seed_source.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all deck assets parse with 30 valid cards each', () async {
    final decks = await const AssetSeedSource().load();

    expect(decks, hasLength(8));
    expect(decks.map((deck) => deck.id).toSet(), hasLength(8));

    for (final deck in decks) {
      expect(deck.name, isNotEmpty, reason: 'deck ${deck.id}');
      expect(deck.description, isNotEmpty, reason: deck.name);
      expect(deck.icon, isNotEmpty, reason: deck.name);
      expect(deck.cards, hasLength(30), reason: deck.name);

      final difficultyCounts = <DifficultyTag, int>{};
      for (final card in deck.cards) {
        expect(card.prompt, isNotEmpty, reason: deck.name);
        expect(card.answer, isNotEmpty, reason: deck.name);
        expect(card.example, isNotEmpty, reason: deck.name);
        difficultyCounts.update(
          card.difficultyTag,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }

      expect(
        difficultyCounts.keys,
        containsAll(DifficultyTag.values),
        reason: '${deck.name} must mix all difficulty tags',
      );
    }
  });

  test('every deck mixes flip and multiple choice cards', () async {
    final decks = await const AssetSeedSource().load();

    for (final deck in decks) {
      final flipCount = deck.cards
          .where((card) => card.type == CardType.flip)
          .length;
      final multipleChoiceCount = deck.cards
          .where((card) => card.type == CardType.multipleChoice)
          .length;

      expect(flipCount, greaterThanOrEqualTo(18), reason: deck.name);
      expect(multipleChoiceCount, greaterThanOrEqualTo(12), reason: deck.name);
    }
  });
}
