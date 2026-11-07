import 'dart:math';

import 'package:linuxdojo/core/database/app_database.dart';

class DistractorGenerator {
  const DistractorGenerator({this.optionCount = 4});

  final int optionCount;

  List<String> buildOptions({
    required CardEntry card,
    required Iterable<CardEntry> deckCards,
    Random? random,
  }) {
    final correct = card.answer.trim();
    final rng = random ?? Random();
    final seen = <String>{correct};
    final distractors = <String>[];

    for (final other in deckCards) {
      if (other.id == card.id) continue;
      if (other.type != card.type) continue;

      final answer = other.answer.trim();
      if (answer.isEmpty || !seen.add(answer)) continue;

      distractors.add(answer);
    }

    distractors.shuffle(rng);
    final options = <String>[
      correct,
      ...distractors.take(max(0, optionCount - 1)),
    ];
    options.shuffle(rng);
    return options;
  }
}
