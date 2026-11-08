import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/stats/data/achievement_repository.dart';
import 'package:linuxdojo/features/stats/data/stats_repository.dart';
import 'package:linuxdojo/features/study/data/review_repository.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';
import 'package:linuxdojo/features/study/presentation/study_session_provider.dart';
import 'package:linuxdojo/features/study/presentation/study_session_state.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late ProviderSubscription<AsyncValue<StudySessionState>> subscription;
  late DateTime now;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
    now = DateTime(2026, 3, 1, 10);

    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(() => now),
        sessionRandomProvider.overrideWithValue(Random(3)),
      ],
    );
    subscription = container.listen(studySessionProvider, (_, _) {});
  });

  tearDown(() async {
    subscription.close();
    container.dispose();
    await database.close();
  });

  test(
    'loads mixed due cards and builds four options for each MC card',
    () async {
      final state = await container.read(studySessionProvider.future);

      expect(state.cards, hasLength(8));
      expect(
        state.cards.where((card) => card.card.type == CardType.flip),
        hasLength(4),
      );
      expect(state.cards.where((card) => card.isMultipleChoice), hasLength(4));
      expect(state.cards[0].card.type, CardType.flip);
      expect(state.cards[1].isMultipleChoice, isTrue);
      expect(state.cards[1].options, hasLength(4));
      expect(state.cards[1].options, contains(state.cards[1].card.answer));
      expect(state.cards[1].options.toSet(), hasLength(4));
      expect(state.currentIndex, 0);
      expect(state.isRevealed, isFalse);
      expect(state.startedAt, now);
    },
  );

  test('shuffles due cards instead of using database order', () async {
    final state = await container.read(studySessionProvider.future);
    final ids = state.cards.map((card) => card.card.id).toList();

    expect(ids, isNot(orderedEquals([1, 2, 3, 4, 5, 6, 7, 8])));
    expect(ids.toSet(), {1, 2, 3, 4, 5, 6, 7, 8});
  });

  test('uses a different card order when a session is restarted', () async {
    final first = await container.read(studySessionProvider.future);
    final firstIds = first.cards.map((card) => card.card.id).toList();

    container.invalidate(studySessionProvider);

    final second = await container.read(studySessionProvider.future);
    final secondIds = second.cards.map((card) => card.card.id).toList();

    expect(secondIds, isNot(orderedEquals(firstIds)));
    expect(secondIds.toSet(), firstIds.toSet());
  });

  test('reveals the current flip card', () async {
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);

    notifier.reveal();

    final state = container.read(studySessionProvider).requireValue;
    expect(state.isRevealed, isTrue);
  });

  test('does not reveal a multiple choice card', () async {
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);
    notifier.reveal();
    await notifier.grade(ReviewGrade.good);

    notifier.reveal();

    final state = container.read(studySessionProvider).requireValue;
    expect(state.currentCard!.isMultipleChoice, isTrue);
    expect(state.isRevealed, isFalse);
  });

  test('selects an MC option and reports whether it is correct', () async {
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);
    notifier.reveal();
    await notifier.grade(ReviewGrade.good);

    final current = container.read(studySessionProvider).requireValue;
    final correct = current.currentCard!.card.answer;
    final wrong = current.currentCard!.options.firstWhere(
      (option) => option != correct,
    );

    notifier.selectOption(correct);

    final state = container.read(studySessionProvider).requireValue;
    expect(state.selectedOption, correct);
    expect(state.isAnswered, isTrue);
    expect(state.isCorrect, isTrue);

    notifier.selectOption(wrong);

    expect(
      container.read(studySessionProvider).requireValue.selectedOption,
      correct,
    );
  });

  test('grades a correct MC answer as Good and advances', () async {
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);
    notifier.reveal();
    await notifier.grade(ReviewGrade.good);

    final cardId = container
        .read(studySessionProvider)
        .requireValue
        .currentCard!
        .card
        .id;
    notifier.selectOption(
      container
          .read(studySessionProvider)
          .requireValue
          .currentCard!
          .card
          .answer,
    );
    await notifier.continueAfterMultipleChoice();

    final state = container.read(studySessionProvider).requireValue;
    expect(state.currentIndex, 2);
    expect(state.reviewedCount, 2);
    expect(state.correctCount, 2);
    expect(state.isAnswered, isFalse);

    final review = await ReviewRepository(database).getState(cardId);
    expect(review, isNotNull);
    expect(review!.repetitions, 1);
    expect(review.interval, 1);
  });

  test('auto-grades a wrong MC answer as Again', () async {
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);
    notifier.reveal();
    await notifier.grade(ReviewGrade.good);

    final mcCard = container
        .read(studySessionProvider)
        .requireValue
        .currentCard!;
    final wrongOption = mcCard.options.firstWhere(
      (option) => option != mcCard.card.answer,
    );

    notifier.selectOption(wrongOption);
    await notifier.continueAfterMultipleChoice();

    final state = container.read(studySessionProvider).requireValue;
    expect(state.reviewedCount, 2);
    expect(state.correctCount, 1);

    final review = await ReviewRepository(database).getState(mcCard.card.id);
    expect(review, isNotNull);
    expect(review!.repetitions, 0);
    expect(review.interval, 1);
    expect(review.easeFactor, closeTo(1.7, 1e-9));
  });

  test('counts Again as an incorrect answer', () async {
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);
    notifier.reveal();

    await notifier.grade(ReviewGrade.again);

    final state = container.read(studySessionProvider).requireValue;
    expect(state.reviewedCount, 1);
    expect(state.correctCount, 0);

    final review = await ReviewRepository(database).getState(1);
    expect(review, isNotNull);
    expect(review!.repetitions, 0);
    expect(review.easeFactor, closeTo(1.7, 1e-9));
  });

  test('records the completed mixed session and builds a summary', () async {
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);

    for (var index = 0; index < 8; index++) {
      final current = container.read(studySessionProvider).requireValue;
      final studyCard = current.currentCard!;
      now = now.add(const Duration(seconds: 10));

      if (studyCard.isMultipleChoice) {
        notifier.selectOption(studyCard.card.answer);
        await notifier.continueAfterMultipleChoice();
      } else {
        notifier.reveal();
        await notifier.grade(ReviewGrade.good);
      }
    }

    final state = container.read(studySessionProvider).requireValue;
    expect(state.isComplete, isTrue);
    expect(state.summary, isNotNull);
    expect(state.summary!.cardsReviewed, 8);
    expect(state.summary!.correctAnswers, 8);
    expect(state.summary!.elapsed, const Duration(seconds: 80));
    expect(state.summary!.dailyCards, 8);
    expect(state.summary!.dailyGoal, SettingsRepository.defaultDailyGoal);
    expect(state.summary!.dailyGoalMet, isFalse);

    final sessions = await SessionRepository(database).getSessions();
    expect(sessions, hasLength(1));
    expect(sessions.single.cardsReviewed, 8);
    expect(sessions.single.correctAnswers, 8);
    expect(sessions.single.multipleChoiceAnswered, 4);
    expect(sessions.single.multipleChoiceCorrect, 4);
    expect(sessions.single.bestMultipleChoiceStreak, 4);
    expect(
      await AchievementRepository(database).isUnlocked('first_session'),
      isTrue,
    );
  });

  test('marks the streak status met when the daily goal is reached', () async {
    await SettingsRepository(database)
        .set(SettingsRepository.dailyGoalKey, '8');

    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);

    for (var index = 0; index < 8; index++) {
      final current = container.read(studySessionProvider).requireValue;
      final studyCard = current.currentCard!;

      if (studyCard.isMultipleChoice) {
        notifier.selectOption(studyCard.card.answer);
        await notifier.continueAfterMultipleChoice();
      } else {
        notifier.reveal();
        await notifier.grade(ReviewGrade.good);
      }
    }

    final summary = container.read(studySessionProvider).requireValue.summary;
    expect(summary, isNotNull);
    expect(summary!.dailyGoal, 8);
    expect(summary.dailyGoalMet, isTrue);
  });

  test('persists progress after each grade so Home and Stats update', () async {
    await SettingsRepository(database).setDailyGoal(1);
    await container.read(studySessionProvider.future);
    final notifier = container.read(studySessionProvider.notifier);

    notifier.reveal();
    await notifier.grade(ReviewGrade.good);

    final sessions = await SessionRepository(database).getSessions();
    expect(sessions, hasLength(1));
    expect(sessions.single.cardsReviewed, 1);
    expect(sessions.single.correctAnswers, 1);

    final stats = await StatsRepository(
      database,
      SettingsRepository(database),
      () => now,
    ).getUserStats();
    expect(stats.cardsReviewedToday, 1);
    expect(stats.dailyGoalMet, isTrue);
    expect(stats.currentStreak, 1);
  });

  test('limits a session to the default daily goal of 10 cards', () async {
    await _insertDueCards(database, now, 6);
    container.invalidate(studySessionProvider);

    final state = await container.read(studySessionProvider.future);

    expect(state.cards, hasLength(10));
    expect(state.total, 10);
  });

  test('limits a session to 20 cards when the daily goal is 20', () async {
    await SettingsRepository(database).setDailyGoal(20);
    await _insertDueCards(database, now, 12);
    container.invalidate(studySessionProvider);

    final state = await container.read(studySessionProvider.future);

    expect(state.cards, hasLength(20));
    expect(state.total, 20);
  });
}

Future<void> _insertDueCards(
  AppDatabase database,
  DateTime now,
  int count,
) async {
  for (var index = 0; index < count; index++) {
    final cardId = await database
        .into(database.cards)
        .insert(
          CardsCompanion.insert(
            deckId: 1,
            prompt: 'Extra prompt $index',
            answer: 'Extra answer $index',
            example: 'extra-$index',
            type: CardType.flip,
            difficultyTag: DifficultyTag.novice,
          ),
        );
    await database
        .into(database.reviews)
        .insert(
          ReviewsCompanion.insert(cardId: Value(cardId), nextReview: now),
        );
  }
}
