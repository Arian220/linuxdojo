import 'package:linuxdojo/core/database/seed/seed_models.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';

const sampleDecks = [
  DeckSeed(
    id: 1,
    name: 'Basics',
    description: 'Essential terminal commands.',
    icon: 'terminal',
    cards: [
      CardSeed(
        prompt: 'What does `pwd` do?',
        answer: 'Prints the current working directory.',
        example: 'pwd',
        type: CardType.flip,
        difficultyTag: DifficultyTag.novice,
      ),
      CardSeed(
        prompt: 'Which command lists directory contents?',
        answer: 'ls',
        example: 'ls -la',
        type: CardType.multipleChoice,
        difficultyTag: DifficultyTag.novice,
        options: ['ls', 'cd', 'pwd'],
      ),
    ],
  ),
  DeckSeed(
    id: 2,
    name: 'Permissions',
    description: 'Ownership and access control.',
    icon: 'lock',
    cards: [
      CardSeed(
        prompt: 'What does `chmod +x script.sh` do?',
        answer: 'Adds execute permission to script.sh.',
        example: 'chmod +x script.sh',
        type: CardType.flip,
        difficultyTag: DifficultyTag.user,
      ),
    ],
  ),
];
