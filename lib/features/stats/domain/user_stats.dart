class UserStats {
  const UserStats({
    required this.totalSessions,
    required this.cardsReviewed,
    required this.correctAnswers,
    required this.multipleChoiceAnswered,
    required this.multipleChoiceCorrect,
    required this.bestMultipleChoiceStreak,
    required this.currentStreak,
    required this.longestStreak,
    required this.daysGoalMet,
    required this.cardsReviewedToday,
    required this.dailyGoal,
    required this.masteredCards,
    required this.totalCards,
  });

  final int totalSessions;
  final int cardsReviewed;
  final int correctAnswers;
  final int multipleChoiceAnswered;
  final int multipleChoiceCorrect;
  final int bestMultipleChoiceStreak;
  final int currentStreak;
  final int longestStreak;
  final int daysGoalMet;
  final int cardsReviewedToday;
  final int dailyGoal;
  final int masteredCards;
  final int totalCards;

  double get accuracy =>
      cardsReviewed == 0 ? 0 : correctAnswers / cardsReviewed;

  double get multipleChoiceAccuracy => multipleChoiceAnswered == 0
      ? 0
      : multipleChoiceCorrect / multipleChoiceAnswered;

  bool get dailyGoalMet => cardsReviewedToday >= dailyGoal;

  double get dailyGoalProgress =>
      dailyGoal == 0 ? 0 : (cardsReviewedToday / dailyGoal).clamp(0.0, 1.0);
}
