import 'dart:math';

import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/features/stats/domain/user_stats.dart';
import 'package:linuxdojo/features/stats/domain/weekly_stats.dart';

abstract final class StatsCalculator {
  static UserStats buildUserStats({
    required List<SessionLog> sessions,
    required int dailyGoal,
    required int masteredCards,
    required int totalCards,
    required DateTime now,
  }) {
    final dailyTotals = _dailyTotals(sessions);
    final today = _dateOnly(now);
    final goalDays = dailyTotals.entries
        .where((entry) => entry.value.cardsReviewed >= dailyGoal)
        .map((entry) => entry.key)
        .toSet();

    final todayTotals = dailyTotals[today] ?? const _DayTotals();

    return UserStats(
      totalSessions: sessions.length,
      cardsReviewed: sessions.fold(
        0,
        (total, session) => total + session.cardsReviewed,
      ),
      correctAnswers: sessions.fold(
        0,
        (total, session) => total + session.correctAnswers,
      ),
      multipleChoiceAnswered: sessions.fold(
        0,
        (total, session) => total + session.multipleChoiceAnswered,
      ),
      multipleChoiceCorrect: sessions.fold(
        0,
        (total, session) => total + session.multipleChoiceCorrect,
      ),
      bestMultipleChoiceStreak: sessions.fold(
        0,
        (best, session) => max(best, session.bestMultipleChoiceStreak),
      ),
      currentStreak: _currentStreak(goalDays, today),
      longestStreak: _longestStreak(goalDays),
      daysGoalMet: goalDays.length,
      cardsReviewedToday: todayTotals.cardsReviewed,
      dailyGoal: dailyGoal,
      masteredCards: masteredCards,
      totalCards: totalCards,
    );
  }

  static WeeklyStats buildWeeklyStats({
    required List<SessionLog> sessions,
    required DateTime now,
  }) {
    final dailyTotals = _dailyTotals(sessions);
    final today = _dateOnly(now);

    final days = List<DailyActivity>.generate(7, (index) {
      final date = _shiftDays(today, index - 6);
      final totals = dailyTotals[date] ?? const _DayTotals();
      return DailyActivity(
        date: date,
        cardsReviewed: totals.cardsReviewed,
        correctAnswers: totals.correctAnswers,
      );
    });

    return WeeklyStats(
      days: days,
      cardsReviewed: days.fold(0, (total, day) => total + day.cardsReviewed),
      correctAnswers: days.fold(0, (total, day) => total + day.correctAnswers),
    );
  }

  static Map<DateTime, _DayTotals> _dailyTotals(List<SessionLog> sessions) {
    final totals = <DateTime, _DayTotals>{};

    for (final session in sessions) {
      final date = _dateOnly(session.startedAt);
      final current = totals[date] ?? const _DayTotals();
      totals[date] = _DayTotals(
        cardsReviewed: current.cardsReviewed + session.cardsReviewed,
        correctAnswers: current.correctAnswers + session.correctAnswers,
      );
    }

    return totals;
  }

  static int _currentStreak(Set<DateTime> goalDays, DateTime today) {
    var cursor = goalDays.contains(today) ? today : _shiftDays(today, -1);

    var streak = 0;
    while (goalDays.contains(cursor)) {
      streak++;
      cursor = _shiftDays(cursor, -1);
    }

    return streak;
  }

  static int _longestStreak(Set<DateTime> goalDays) {
    if (goalDays.isEmpty) return 0;

    final sorted = goalDays.toList()..sort();
    var longest = 1;
    var run = 1;

    for (var index = 1; index < sorted.length; index++) {
      final previous = sorted[index - 1];
      final current = sorted[index];
      if (_shiftDays(previous, 1) == current) {
        run++;
        longest = max(longest, run);
      } else {
        run = 1;
      }
    }

    return longest;
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime _shiftDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);
}

class _DayTotals {
  const _DayTotals({this.cardsReviewed = 0, this.correctAnswers = 0});

  final int cardsReviewed;
  final int correctAnswers;
}
