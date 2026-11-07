import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';

class DeckSeed {
  const DeckSeed({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.cards,
  });

  factory DeckSeed.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'] as List<dynamic>;
    return DeckSeed(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      cards: rawCards
          .map((card) => CardSeed.fromJson(card as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  final int id;
  final String name;
  final String description;
  final String icon;
  final List<CardSeed> cards;
}

class CardSeed {
  const CardSeed({
    required this.prompt,
    required this.answer,
    required this.example,
    required this.type,
    required this.difficultyTag,
    this.options,
  });

  factory CardSeed.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>?;
    return CardSeed(
      prompt: json['prompt'] as String,
      answer: json['answer'] as String,
      example: json['example'] as String,
      type: CardType.fromValue(json['type'] as String),
      difficultyTag: DifficultyTag.fromValue(json['difficulty_tag'] as String),
      options: rawOptions?.cast<String>(),
    );
  }

  final String prompt;
  final String answer;
  final String example;
  final CardType type;
  final DifficultyTag difficultyTag;
  final List<String>? options;
}
