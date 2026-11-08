import 'package:linuxdojo/features/study/domain/study_card.dart';

class StudySessionState {
  const StudySessionState({
    required this.cards,
    required this.currentIndex,
    required this.isRevealed,
    required this.startedAt,
    required this.reviewedCount,
    required this.correctCount,
    required this.multipleChoiceAnswered,
    required this.multipleChoiceCorrect,
    required this.currentMultipleChoiceStreak,
    required this.bestMultipleChoiceStreak,
    required this.isGrading,
    this.selectedOption,
    this.finishedAt,
    this.summary,
  });

  final List<StudyCard> cards;
  final int currentIndex;
  final bool isRevealed;
  final DateTime startedAt;
  final int reviewedCount;
  final int correctCount;
  final int multipleChoiceAnswered;
  final int multipleChoiceCorrect;
  final int currentMultipleChoiceStreak;
  final int bestMultipleChoiceStreak;
  final bool isGrading;
  final String? selectedOption;
  final DateTime? finishedAt;
  final StudySessionSummary? summary;

  bool get hasCards => cards.isNotEmpty;
  bool get isComplete => hasCards && currentIndex >= cards.length;
  int get total => cards.length;
  StudyCard? get currentCard =>
      currentIndex < cards.length ? cards[currentIndex] : null;
  double get progress => total == 0 ? 0 : currentIndex / total;

  bool get isMultipleChoice => currentCard?.isMultipleChoice ?? false;
  bool get isAnswered => selectedOption != null;
  bool get isCorrect => selectedOption == currentCard?.card.answer;

  StudySessionState copyWith({
    int? currentIndex,
    bool? isRevealed,
    int? reviewedCount,
    int? correctCount,
    int? multipleChoiceAnswered,
    int? multipleChoiceCorrect,
    int? currentMultipleChoiceStreak,
    int? bestMultipleChoiceStreak,
    bool? isGrading,
    String? selectedOption,
    bool clearSelection = false,
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
      multipleChoiceAnswered:
          multipleChoiceAnswered ?? this.multipleChoiceAnswered,
      multipleChoiceCorrect:
          multipleChoiceCorrect ?? this.multipleChoiceCorrect,
      currentMultipleChoiceStreak:
          currentMultipleChoiceStreak ?? this.currentMultipleChoiceStreak,
      bestMultipleChoiceStreak:
          bestMultipleChoiceStreak ?? this.bestMultipleChoiceStreak,
      isGrading: isGrading ?? this.isGrading,
      selectedOption: clearSelection
          ? null
          : (selectedOption ?? this.selectedOption),
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
