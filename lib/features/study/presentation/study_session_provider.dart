import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/study/data/review_repository.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';
import 'package:linuxdojo/features/study/data/study_repository.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';
import 'package:linuxdojo/features/study/presentation/study_session_state.dart';

final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final dueCardsProvider = StreamProvider<List<CardEntry>>((ref) {
  return ref.watch(studyRepositoryProvider).watchDueCards();
});

final dueFlipCardsProvider = Provider<AsyncValue<List<CardEntry>>>((ref) {
  return ref
      .watch(dueCardsProvider)
      .whenData(
        (cards) => cards
            .where((card) => card.type == CardType.flip)
            .toList(growable: false),
      );
});

final studySessionProvider =
    AsyncNotifierProvider.autoDispose<StudySessionNotifier, StudySessionState>(
      StudySessionNotifier.new,
    );

class StudySessionNotifier extends AsyncNotifier<StudySessionState> {
  @override
  Future<StudySessionState> build() async {
    final dueCards = await ref.watch(studyRepositoryProvider).getDueCards();
    final cards = dueCards.where((card) => card.type == CardType.flip).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return StudySessionState(
      cards: cards,
      currentIndex: 0,
      isRevealed: false,
      startedAt: _now(),
      reviewedCount: 0,
      correctCount: 0,
      isGrading: false,
    );
  }

  void reveal() {
    final current = state.value;
    if (current == null ||
        !current.hasCards ||
        current.isComplete ||
        current.isRevealed ||
        current.isGrading) {
      return;
    }

    state = AsyncData(current.copyWith(isRevealed: true));
  }

  Future<void> grade(ReviewGrade grade) async {
    final current = state.value;
    if (current == null ||
        !current.hasCards ||
        current.isComplete ||
        !current.isRevealed ||
        current.isGrading) {
      return;
    }

    final card = current.currentCard;
    if (card == null) return;

    state = AsyncData(current.copyWith(isGrading: true));

    try {
      final reviewedAt = _now();
      await ref
          .read(reviewRepositoryProvider)
          .applyGrade(cardId: card.id, grade: grade, reviewedAt: reviewedAt);
      if (!ref.mounted) return;

      final reviewedCount = current.reviewedCount + 1;
      final correctCount =
          current.correctCount + (grade == ReviewGrade.again ? 0 : 1);
      final nextIndex = current.currentIndex + 1;
      final isComplete = nextIndex >= current.cards.length;

      StudySessionSummary? summary;
      DateTime? finishedAt;

      if (isComplete) {
        finishedAt = reviewedAt;
        final sessionRepository = ref.read(sessionRepositoryProvider);
        await sessionRepository.recordSession(
          startedAt: current.startedAt,
          endedAt: reviewedAt,
          cardsReviewed: reviewedCount,
          correctAnswers: correctCount,
        );
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
          reviewedCount: reviewedCount,
          correctCount: correctCount,
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
