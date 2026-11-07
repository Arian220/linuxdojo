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
      CardSeed(
        prompt: 'What does `cd /tmp` do?',
        answer: 'Changes the current directory to /tmp.',
        example: 'cd /tmp\npwd',
        type: CardType.flip,
        difficultyTag: DifficultyTag.novice,
      ),
      CardSeed(
        prompt: 'Which command creates a directory?',
        answer: 'mkdir',
        example: 'mkdir notes',
        type: CardType.multipleChoice,
        difficultyTag: DifficultyTag.novice,
      ),
      CardSeed(
        prompt: 'Which command searches text for a pattern?',
        answer: 'grep',
        example: 'grep -r TODO .',
        type: CardType.multipleChoice,
        difficultyTag: DifficultyTag.user,
      ),
      CardSeed(
        prompt: 'What does `ls -l` do?',
        answer: 'Lists files with their permissions and details.',
        example: 'ls -l',
        type: CardType.flip,
        difficultyTag: DifficultyTag.user,
      ),
      CardSeed(
        prompt: 'Which command creates an empty file?',
        answer: 'touch',
        example: 'touch notes.txt',
        type: CardType.multipleChoice,
        difficultyTag: DifficultyTag.novice,
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
