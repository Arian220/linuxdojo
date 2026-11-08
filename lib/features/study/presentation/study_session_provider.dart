import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/notifications/data/reminder_service.dart';
import 'package:linuxdojo/features/stats/data/achievement_service.dart';
import 'package:linuxdojo/features/study/data/review_repository.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';
import 'package:linuxdojo/features/study/data/study_repository.dart';
import 'package:linuxdojo/features/study/domain/distractor_generator.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';
import 'package:linuxdojo/features/study/domain/study_card.dart';
import 'package:linuxdojo/features/study/presentation/study_session_state.dart';

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final distractorGeneratorProvider = Provider<DistractorGenerator>(
  (ref) => const DistractorGenerator(),
);

final sessionRandomProvider = Provider<Random>((ref) => Random());

final dueCardsProvider = StreamProvider<List<CardEntry>>((ref) {
  return ref.watch(studyRepositoryProvider).watchDueCards();
});

final studySessionProvider =
    AsyncNotifierProvider.autoDispose<StudySessionNotifier, StudySessionState>(
      StudySessionNotifier.new,
    );

class StudySessionNotifier extends AsyncNotifier<StudySessionState> {
  int? _sessionLogId;

  @override
  Future<StudySessionState> build() async {
    final repository = ref.watch(studyRepositoryProvider);
    final dailyGoal = await ref.read(settingsRepositoryProvider).getDailyGoal();
    final dueCards = await repository.getDueCards();
    final random = ref.read(sessionRandomProvider);
    final shuffled = dueCards.toList()..shuffle(random);
    final sessionCards = shuffled.take(dailyGoal);

    final generator = ref.read(distractorGeneratorProvider);
    final deckCards = <int, List<CardEntry>>{};
    final cards = <StudyCard>[];

    for (final card in sessionCards) {
      if (card.type == CardType.multipleChoice) {
        final pool = deckCards[card.deckId] ??= await repository
            .getCardsForDeck(card.deckId);
        cards.add(
          StudyCard(
            card: card,
            options: generator.buildOptions(
              card: card,
              deckCards: pool,
              random: random,
            ),
          ),
        );
      } else {
        cards.add(StudyCard(card: card));
      }
    }

    return StudySessionState(
      cards: cards,
      currentIndex: 0,
      isRevealed: false,
      startedAt: _now(),
      reviewedCount: 0,
      correctCount: 0,
      multipleChoiceAnswered: 0,
      multipleChoiceCorrect: 0,
      currentMultipleChoiceStreak: 0,
      bestMultipleChoiceStreak: 0,
      isGrading: false,
    );
  }

  void reveal() {
    final current = state.value;
    if (current == null ||
        !current.hasCards ||
        current.isComplete ||
        current.isRevealed ||
        current.isGrading ||
        current.isMultipleChoice) {
      return;
    }

    state = AsyncData(current.copyWith(isRevealed: true));
  }

  void selectOption(String option) {
    final current = state.value;
    if (current == null ||
        !current.hasCards ||
        current.isComplete ||
        current.isGrading ||
        !current.isMultipleChoice ||
        current.isAnswered) {
      return;
    }

    final card = current.currentCard;
    if (card == null || !card.options.contains(option)) return;

    state = AsyncData(current.copyWith(selectedOption: option));
  }

  Future<void> continueAfterMultipleChoice() async {
    final current = state.value;
    if (current == null ||
        !current.hasCards ||
        current.isComplete ||
        current.isGrading ||
        !current.isMultipleChoice ||
        !current.isAnswered) {
      return;
    }

    await _applyGrade(
      ReviewGrade.fromMultipleChoice(correct: current.isCorrect),
    );
  }

  Future<void> grade(ReviewGrade grade) async {
    final current = state.value;
    if (current == null ||
        !current.hasCards ||
        current.isComplete ||
        !current.isRevealed ||
        current.isGrading ||
        current.isMultipleChoice) {
      return;
    }

    await _applyGrade(grade);
  }

  Future<void> _applyGrade(ReviewGrade grade) async {
    final current = state.value;
    if (current == null) return;

    final studyCard = current.currentCard;
    if (studyCard == null) return;

    state = AsyncData(current.copyWith(isGrading: true));

    try {
      final reviewedAt = _now();
      await ref
          .read(reviewRepositoryProvider)
          .applyGrade(
            cardId: studyCard.card.id,
            grade: grade,
            reviewedAt: reviewedAt,
          );
      if (!ref.mounted) return;

      final isCorrect = grade != ReviewGrade.again;
      final isMultipleChoice = studyCard.isMultipleChoice;
      final reviewedCount = current.reviewedCount + 1;
      final correctCount = current.correctCount + (isCorrect ? 1 : 0);
      final multipleChoiceAnswered =
          current.multipleChoiceAnswered + (isMultipleChoice ? 1 : 0);
      final multipleChoiceCorrect =
          current.multipleChoiceCorrect +
          (isMultipleChoice && isCorrect ? 1 : 0);
      final currentMultipleChoiceStreak = isMultipleChoice
          ? (isCorrect ? current.currentMultipleChoiceStreak + 1 : 0)
          : current.currentMultipleChoiceStreak;
      final bestMultipleChoiceStreak = max(
        current.bestMultipleChoiceStreak,
        currentMultipleChoiceStreak,
      );
      final nextIndex = current.currentIndex + 1;
      final isComplete = nextIndex >= current.cards.length;
      final sessionRepository = ref.read(sessionRepositoryProvider);
      final sessionLogId = _sessionLogId;

      if (sessionLogId == null) {
        _sessionLogId = await sessionRepository.recordSession(
          startedAt: current.startedAt,
          endedAt: reviewedAt,
          cardsReviewed: reviewedCount,
          correctAnswers: correctCount,
          multipleChoiceAnswered: multipleChoiceAnswered,
          multipleChoiceCorrect: multipleChoiceCorrect,
          bestMultipleChoiceStreak: bestMultipleChoiceStreak,
        );
      } else {
        await sessionRepository.updateSession(
          id: sessionLogId,
          endedAt: reviewedAt,
          cardsReviewed: reviewedCount,
          correctAnswers: correctCount,
          multipleChoiceAnswered: multipleChoiceAnswered,
          multipleChoiceCorrect: multipleChoiceCorrect,
          bestMultipleChoiceStreak: bestMultipleChoiceStreak,
        );
      }
      if (!ref.mounted) return;

      StudySessionSummary? summary;
      DateTime? finishedAt;

      if (isComplete) {
        finishedAt = reviewedAt;
        try {
          await ref.read(reminderServiceProvider).sync(now: reviewedAt);
        } catch (error, stackTrace) {
          debugPrint(
            'Could not refresh reminder after study: $error\n$stackTrace',
          );
        }
        if (!ref.mounted) return;

        try {
          await ref.read(achievementServiceProvider).sync();
        } catch (_) {}
        if (!ref.mounted) return;

        final dailyGoal = await ref
            .read(settingsRepositoryProvider)
            .getDailyGoal();
        if (!ref.mounted) return;

        final startOfDay = DateTime(
          reviewedAt.year,
          reviewedAt.month,
          reviewedAt.day,
        );
        final sessions = await sessionRepository.getSessionsSince(startOfDay);
        if (!ref.mounted) return;

        final dailyCards = sessions.fold<int>(
          0,
          (total, session) => total + session.cardsReviewed,
        );
        summary = StudySessionSummary(
          cardsReviewed: reviewedCount,
          correctAnswers: correctCount,
          elapsed: reviewedAt.difference(current.startedAt),
          dailyCards: dailyCards,
          dailyGoal: dailyGoal,
        );
      }

      state = AsyncData(
        current.copyWith(
          currentIndex: nextIndex,
          isRevealed: false,
          clearSelection: true,
          reviewedCount: reviewedCount,
          correctCount: correctCount,
          multipleChoiceAnswered: multipleChoiceAnswered,
          multipleChoiceCorrect: multipleChoiceCorrect,
          currentMultipleChoiceStreak: currentMultipleChoiceStreak,
          bestMultipleChoiceStreak: bestMultipleChoiceStreak,
          isGrading: false,
          finishedAt: finishedAt,
          summary: summary,
        ),
      );
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncError(error, stackTrace);
    }
  }

  DateTime _now() => ref.read(clockProvider)();
}
