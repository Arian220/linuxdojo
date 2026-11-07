import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';
import 'package:linuxdojo/features/study/domain/review_state.dart';
import 'package:linuxdojo/features/study/domain/sm2_engine.dart';

void main() {
  const engine = Sm2Engine();
  final reviewedAt = DateTime(2026, 1, 10, 9);

  ReviewState initial() => ReviewState.initial(reviewedAt);

  group('grade mapping', () {
    test('multiple choice correct maps to Good', () {
      expect(ReviewGrade.fromMultipleChoice(correct: true), ReviewGrade.good);
    });

    test('multiple choice wrong maps to Again', () {
      expect(ReviewGrade.fromMultipleChoice(correct: false), ReviewGrade.again);
    });
  });

  group('first review', () {
    test('Good schedules one day without changing ease', () {
      final next = engine.schedule(
        current: initial(),
        grade: ReviewGrade.good,
        reviewedAt: reviewedAt,
      );

      expect(next.interval, 1);
      expect(next.repetitions, 1);
      expect(next.easeFactor, closeTo(2.5, 1e-9));
      expect(next.nextReview, reviewedAt.add(const Duration(days: 1)));
      expect(next.lastReview, reviewedAt);
    });

    test('Easy schedules one day and increases ease', () {
      final next = engine.schedule(
        current: initial(),
        grade: ReviewGrade.easy,
        reviewedAt: reviewedAt,
      );

      expect(next.interval, 1);
      expect(next.repetitions, 1);
      expect(next.easeFactor, closeTo(2.6, 1e-9));
    });

    test('Hard schedules one day and decreases ease', () {
      final next = engine.schedule(
        current: initial(),
        grade: ReviewGrade.hard,
        reviewedAt: reviewedAt,
      );

      expect(next.interval, 1);
      expect(next.repetitions, 1);
      expect(next.easeFactor, closeTo(2.36, 1e-9));
    });

    test('Again resets repetitions and schedules one day', () {
      final current = ReviewState(
        interval: 15,
        easeFactor: 2.5,
        repetitions: 3,
        nextReview: reviewedAt,
        lastReview: reviewedAt,
      );

      final next = engine.schedule(
        current: current,
        grade: ReviewGrade.again,
        reviewedAt: reviewedAt,
      );

      expect(next.interval, 1);
      expect(next.repetitions, 0);
      expect(next.easeFactor, closeTo(1.7, 1e-9));
      expect(next.nextReview, reviewedAt.add(const Duration(days: 1)));
      expect(next.lastReview, reviewedAt);
    });
  });

  group('known SM-2 sequences', () {
    test('Good, Good, Good produces 1, 6, and 15 day intervals', () {
      var state = initial();

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.good,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 1);

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.good,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 6);

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.good,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 15);
      expect(state.repetitions, 3);
      expect(state.easeFactor, closeTo(2.5, 1e-9));
    });

    test('Easy, Easy, Easy grows intervals and ease', () {
      var state = initial();

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.easy,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 1);
      expect(state.easeFactor, closeTo(2.6, 1e-9));

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.easy,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 6);
      expect(state.easeFactor, closeTo(2.7, 1e-9));

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.easy,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 16);
      expect(state.easeFactor, closeTo(2.8, 1e-9));
    });

    test('Hard, Hard, Hard shrinks ease and grows intervals', () {
      var state = initial();

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.hard,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 1);
      expect(state.easeFactor, closeTo(2.36, 1e-9));

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.hard,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 6);
      expect(state.easeFactor, closeTo(2.22, 1e-9));

      state = engine.schedule(
        current: state,
        grade: ReviewGrade.hard,
        reviewedAt: reviewedAt,
      );
      expect(state.interval, 13);
      expect(state.easeFactor, closeTo(2.08, 1e-9));
    });
  });

  test('ease factor never drops below the minimum', () {
    var state = ReviewState(
      interval: 1,
      easeFactor: 1.3,
      repetitions: 3,
      nextReview: reviewedAt,
    );

    for (var i = 0; i < 5; i++) {
      state = engine.schedule(
        current: state,
        grade: ReviewGrade.again,
        reviewedAt: reviewedAt,
      );
    }

    expect(state.easeFactor, 1.3);
  });
}
