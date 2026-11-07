import 'package:linuxdojo/core/database/app_database.dart';

class StudySessionState {
  const StudySessionState({
    required this.cards,
    required this.currentIndex,
    required this.isRevealed,
    required this.startedAt,
    required this.reviewedCount,
    required this.correctCount,
    required this.isGrading,
    this.finishedAt,
    this.summary,
  });

  final List<CardEntry> cards;
  final int currentIndex;
  final bool isRevealed;
  final DateTime startedAt;
  final int reviewedCount;
  final int correctCount;
  final bool isGrading;
  final DateTime? finishedAt;
  final StudySessionSummary? summary;

  bool get hasCards => cards.isNotEmpty;
  bool get isComplete => hasCards && currentIndex >= cards.length;
  int get total => cards.length;
  CardEntry? get currentCard =>
      currentIndex < cards.length ? cards[currentIndex] : null;
  double get progress => total == 0 ? 0 : currentIndex / total;

  StudySessionState copyWith({
    int? currentIndex,
    bool? isRevealed,
    int? reviewedCount,
    int? correctCount,
    bool? isGrading,
    DateTime? finishedAt,
    StudySessionSummary? summary,
  }) {
    return StudySessionState(
      cards: cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isRevealed: isRevealed ?? this.isRevealed,
      startedAt: startedAt,
      reviewedCount: reviewedCount ?? this.reviewedCount,
      correctCount: correctCount ?? this.correctCount,
      isGrading: isGrading ?? this.isGrading,
      finishedAt: finishedAt ?? this.finishedAt,
      summary: summary ?? this.summary,
    );
  }
}

class StudySessionSummary {
  const StudySessionSummary({
    required this.cardsReviewed,
    required this.correctAnswers,
    required this.elapsed,
    required this.dailyCards,
    required this.dailyGoal,
  });

  final int cardsReviewed;
  final int correctAnswers;
  final Duration elapsed;
  final int dailyCards;
  final int dailyGoal;

  bool get dailyGoalMet => dailyCards >= dailyGoal;
}
