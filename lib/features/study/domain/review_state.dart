class ReviewState {
  const ReviewState({
    required this.interval,
    required this.easeFactor,
    required this.repetitions,
    required this.nextReview,
    this.lastReview,
  });

  factory ReviewState.initial(DateTime now) {
    return ReviewState(
      interval: 0,
      easeFactor: 2.5,
      repetitions: 0,
      nextReview: now,
    );
  }

  final int interval;
  final double easeFactor;
  final int repetitions;
  final DateTime nextReview;
  final DateTime? lastReview;
}
