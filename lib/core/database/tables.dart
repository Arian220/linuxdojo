import 'package:drift/drift.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';

@DataClassName('Deck')
class Decks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text()();
  TextColumn get icon => text()();
}

@DataClassName('CardEntry')
@TableIndex(name: 'cards_deck_id', columns: {#deckId})
class Cards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId =>
      integer().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get prompt => text()();
  TextColumn get answer => text()();
  TextColumn get example => text()();
  TextColumn get type => text().map(const CardTypeConverter())();
  TextColumn get difficultyTag => text().map(const DifficultyTagConverter())();
  TextColumn get options => text().nullable()();
}

@DataClassName('Review')
@TableIndex(name: 'reviews_next_review', columns: {#nextReview})
class Reviews extends Table {
  IntColumn get cardId =>
      integer().references(Cards, #id, onDelete: KeyAction.cascade)();
  IntColumn get interval => integer().withDefault(const Constant(0))();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReview => dateTime()();
  DateTimeColumn get lastReview => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {cardId};
}

@DataClassName('SessionLog')
class SessionLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime()();
  IntColumn get cardsReviewed => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get multipleChoiceAnswered =>
      integer().withDefault(const Constant(0))();
  IntColumn get multipleChoiceCorrect =>
      integer().withDefault(const Constant(0))();
  IntColumn get bestMultipleChoiceStreak =>
      integer().withDefault(const Constant(0))();
}

@DataClassName('Achievement')
class Achievements extends Table {
  TextColumn get id => text()();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Setting')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
