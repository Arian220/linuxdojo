import 'dart:math' as math;

import 'package:linuxdojo/features/study/domain/review_grade.dart';
import 'package:linuxdojo/features/study/domain/review_state.dart';

class Sm2Engine {
  const Sm2Engine({this.minimumEaseFactor = 1.3});

  final double minimumEaseFactor;

  ReviewState schedule({
    required ReviewState current,
    required ReviewGrade grade,
    required DateTime reviewedAt,
  }) {
    final repetitions = grade == ReviewGrade.again
        ? 0
        : current.repetitions + 1;
    final interval = _intervalAfter(
      current.interval,
      repetitions,
      current.easeFactor,
    );
    final easeFactor = _easeFactorAfter(current.easeFactor, grade);

    return ReviewState(
      interval: interval,
      easeFactor: easeFactor,
      repetitions: repetitions,
      nextReview: reviewedAt.add(Duration(days: interval)),
      lastReview: reviewedAt,
    );
  }

  double _easeFactorAfter(double current, ReviewGrade grade) {
    final distance = 5 - grade.quality;
    final delta = 0.1 - distance * (0.08 + distance * 0.02);
    return math.max(minimumEaseFactor, current + delta);
  }

  int _intervalAfter(int previousInterval, int repetitions, double easeFactor) {
    if (repetitions == 0 || repetitions == 1) {
      return 1;
    }
    if (repetitions == 2) {
      return 6;
    }
    return math.max(1, (previousInterval * easeFactor).round());
  }
}
