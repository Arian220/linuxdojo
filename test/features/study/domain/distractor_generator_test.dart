import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';
import 'package:linuxdojo/features/study/domain/distractor_generator.dart';

void main() {
  const generator = DistractorGenerator();

  CardEntry card(
    int id,
    String answer, {
    CardType type = CardType.multipleChoice,
  }) {
    return CardEntry(
      id: id,
      deckId: 1,
      prompt: 'Prompt $id',
      answer: answer,
      example: 'example $id',
      type: type,
      difficultyTag: DifficultyTag.novice,
    );
  }

  test('builds four unique command options including the correct answer', () {
    final target = card(1, 'ls');
    final deck = [
      target,
      card(2, 'cd'),
      card(3, 'pwd'),
      card(4, 'mkdir'),
      card(5, 'grep'),
      card(6, 'Prints the current working directory.', type: CardType.flip),
    ];

    final options = generator.buildOptions(
      card: target,
      deckCards: deck,
      random: Random(7),
    );

    expect(options, hasLength(4));
    expect(options.toSet(), hasLength(4));
    expect(options, contains('ls'));
    expect(
      options.where((option) => option != 'ls'),
      everyElement(isIn(['cd', 'pwd', 'mkdir', 'grep'])),
    );
    expect(options, isNot(contains('Prints the current working directory.')));
  });

  test('ignores flip-card explanations as distractors', () {
    final target = card(1, 'ls');
    final deck = [
      target,
      card(2, 'cd'),
      card(3, 'pwd'),
      card(4, 'Prints the current working directory.', type: CardType.flip),
      card(5, 'Changes the current directory.', type: CardType.flip),
    ];

    final options = generator.buildOptions(
      card: target,
      deckCards: deck,
      random: Random(5),
    );

    expect(options, unorderedEquals(['ls', 'cd', 'pwd']));
    expect(options, isNot(contains('Prints the current working directory.')));
    expect(options, isNot(contains('Changes the current directory.')));
  });

  test('only uses answers from the provided deck', () {
    final target = card(1, 'ls');
    final deck = [target, card(2, 'cd'), card(3, 'pwd'), card(4, 'mkdir')];

    final options = generator.buildOptions(
      card: target,
      deckCards: deck,
      random: Random(3),
    );

    expect(options, everyElement(isIn(['ls', 'cd', 'pwd', 'mkdir'])));
    expect(options, isNot(contains('systemctl')));
  });

  test('is deterministic for a given random seed', () {
    final target = card(1, 'ls');
    final deck = [
      target,
      card(2, 'cd'),
      card(3, 'pwd'),
      card(4, 'mkdir'),
      card(5, 'grep'),
    ];

    final first = generator.buildOptions(
      card: target,
      deckCards: deck,
      random: Random(42),
    );
    final second = generator.buildOptions(
      card: target,
      deckCards: deck,
      random: Random(42),
    );

    expect(first, second);
  });

  test('skips duplicate answers and the card itself', () {
    final target = card(1, 'ls');
    final deck = [target, card(2, 'cd'), card(3, 'cd'), card(4, 'pwd')];

    final options = generator.buildOptions(
      card: target,
      deckCards: deck,
      random: Random(1),
    );

    expect(options, hasLength(3));
    expect(options.where((option) => option == 'cd'), hasLength(1));
  });
}
