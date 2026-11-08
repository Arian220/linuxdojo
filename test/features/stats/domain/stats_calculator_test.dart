import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/features/stats/domain/stats_calculator.dart';

void main() {
  test('builds user stats from sessions and the daily goal', () {
    final now = DateTime(2026, 3, 10, 12);
    final sessions = [
      _session(DateTime(2026, 3, 1), cards: 10, correct: 8),
      _session(DateTime(2026, 3, 2), cards: 10, correct: 8),
      _session(DateTime(2026, 3, 3), cards: 5, correct: 2),
      _session(
        DateTime(2026, 3, 4),
        cards: 10,
        correct: 9,
        mcAnswered: 6,
        mcCorrect: 6,
        bestMcStreak: 6,
      ),
      _session(DateTime(2026, 3, 5), cards: 10, correct: 9),
      _session(
        DateTime(2026, 3, 6),
        cards: 10,
        correct: 9,
        mcAnswered: 4,
        mcCorrect: 3,
        bestMcStreak: 4,
      ),
      _session(
        DateTime(2026, 3, 9),
        cards: 12,
        correct: 10,
        mcAnswered: 5,
        mcCorrect: 5,
        bestMcStreak: 5,
      ),
      _session(
        DateTime(2026, 3, 10),
        cards: 10,
        correct: 10,
        mcAnswered: 7,
        mcCorrect: 7,
        bestMcStreak: 7,
      ),
    ];

    final stats = StatsCalculator.buildUserStats(
      sessions: sessions,
      dailyGoal: 10,
      masteredCards: 24,
      totalCards: 240,
      now: now,
    );

    expect(stats.totalSessions, 8);
    expect(stats.cardsReviewed, 77);
    expect(stats.correctAnswers, 65);
    expect(stats.accuracy, closeTo(65 / 77, 1e-9));
    expect(stats.multipleChoiceAnswered, 22);
    expect(stats.multipleChoiceCorrect, 21);
    expect(stats.multipleChoiceAccuracy, closeTo(21 / 22, 1e-9));
    expect(stats.bestMultipleChoiceStreak, 7);
    expect(stats.currentStreak, 2);
    expect(stats.longestStreak, 3);
    expect(stats.daysGoalMet, 7);
    expect(stats.cardsReviewedToday, 10);
    expect(stats.dailyGoal, 10);
    expect(stats.dailyGoalMet, isTrue);
    expect(stats.masteredCards, 24);
    expect(stats.totalCards, 240);
  });

  test('keeps the streak alive when yesterday met the goal', () {
    final sessions = [
      _session(DateTime(2026, 3, 7), cards: 10),
      _session(DateTime(2026, 3, 8), cards: 10),
      _session(DateTime(2026, 3, 9), cards: 10),
    ];

    final stats = StatsCalculator.buildUserStats(
      sessions: sessions,
      dailyGoal: 10,
      masteredCards: 0,
      totalCards: 0,
      now: DateTime(2026, 3, 10, 12),
    );

    expect(stats.currentStreak, 3);
    expect(stats.longestStreak, 3);
    expect(stats.daysGoalMet, 3);
    expect(stats.cardsReviewedToday, 0);
    expect(stats.dailyGoalMet, isFalse);
  });

  test('builds seven days of weekly activity ending today', () {
    final sessions = [
      _session(DateTime(2026, 3, 3), cards: 9, correct: 7),
      _session(DateTime(2026, 3, 4), cards: 10, correct: 9),
      _session(DateTime(2026, 3, 5), cards: 10, correct: 9),
      _session(DateTime(2026, 3, 6), cards: 10, correct: 9),
      _session(DateTime(2026, 3, 9), cards: 12, correct: 10),
      _session(DateTime(2026, 3, 10), cards: 10, correct: 10),
    ];

    final weekly = StatsCalculator.buildWeeklyStats(
      sessions: sessions,
      now: DateTime(2026, 3, 10, 12),
    );

    expect(weekly.days, hasLength(7));
    expect(weekly.days.first.date, DateTime(2026, 3, 4));
    expect(weekly.days.last.date, DateTime(2026, 3, 10));
    expect(weekly.days.map((day) => day.cardsReviewed), [
      10,
      10,
      10,
      0,
      0,
      12,
      10,
    ]);
    expect(weekly.days.map((day) => day.correctAnswers), [
      9,
      9,
      9,
      0,
      0,
      10,
      10,
    ]);
    expect(weekly.cardsReviewed, 52);
    expect(weekly.correctAnswers, 47);
  });
}

SessionLog _session(
  DateTime startedAt, {
  int cards = 0,
  int correct = 0,
  int mcAnswered = 0,
  int mcCorrect = 0,
  int bestMcStreak = 0,
}) {
  return SessionLog(
    id: 0,
    startedAt: startedAt,
    endedAt: startedAt.add(const Duration(minutes: 10)),
    cardsReviewed: cards,
    correctAnswers: correct,
    multipleChoiceAnswered: mcAnswered,
    multipleChoiceCorrect: mcCorrect,
    bestMultipleChoiceStreak: bestMcStreak,
  );
}
