class DailyActivity {
  const DailyActivity({
    required this.date,
    required this.cardsReviewed,
    required this.correctAnswers,
  });

  final DateTime date;
  final int cardsReviewed;
  final int correctAnswers;
}

class WeeklyStats {
  const WeeklyStats({
    required this.days,
    required this.cardsReviewed,
    required this.correctAnswers,
  });

  final List<DailyActivity> days;
  final int cardsReviewed;
  final int correctAnswers;
}
