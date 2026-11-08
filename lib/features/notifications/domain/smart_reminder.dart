import 'dart:math';

class ReminderWindow {
  const ReminderWindow({this.startHour = 7, this.endHour = 22})
    : assert(startHour >= 0 && startHour < 24),
      assert(endHour > startHour && endHour <= 24);

  final int startHour;
  final int endHour;

  int get startMinutes => startHour * 60;
  int get endMinutes => endHour * 60 - 1;
}

class ReminderSession {
  const ReminderSession({required this.startedAt, required this.endedAt});

  final DateTime startedAt;
  final DateTime endedAt;
}

class ReminderPlan {
  const ReminderPlan({required this.scheduledAt, required this.usedFallback});

  final DateTime scheduledAt;
  final bool usedFallback;
}

class SmartReminder {
  const SmartReminder({
    this.window = const ReminderWindow(),
    this.historyWindow = const Duration(days: 30),
    this.jitterMinutes = 30,
  });

  static const _fallbackMinuteOfDay = 19 * 60;

  final ReminderWindow window;
  final Duration historyWindow;
  final int jitterMinutes;

  ReminderPlan nextReminder({
    required List<ReminderSession> sessions,
    required int currentStreak,
    required int dailyGoal,
    bool dailyGoalMetToday = false,
    required DateTime now,
    required Random random,
  }) {
    final cutoff = now.subtract(historyWindow);
    final recent = sessions
        .where(
          (session) =>
              !session.startedAt.isAfter(now) &&
              !session.startedAt.isBefore(cutoff),
        )
        .toList();

    final fallback = recent.isEmpty;
    var minuteOfDay = fallback
        ? _fallbackMinuteOfDay
        : _sampleMinute(recent, random);

    if (!fallback) {
      final goalSteps = ((dailyGoal - 10) ~/ 10).clamp(0, 2);
      final streakShift = currentStreak == 0 ? -15 : 0;
      minuteOfDay += streakShift - goalSteps * 15;
    }
    minuteOfDay = minuteOfDay.clamp(window.startMinutes, window.endMinutes);

    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    var scheduledAt = DateTime(now.year, now.month, now.day, hour, minute);
    if (dailyGoalMetToday || !scheduledAt.isAfter(now)) {
      scheduledAt = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }

    return ReminderPlan(scheduledAt: scheduledAt, usedFallback: fallback);
  }

  int _sampleMinute(List<ReminderSession> sessions, Random random) {
    final weights = sessions.map(_usageWeight).toList();
    final total = weights.fold<double>(0, (sum, weight) => sum + weight);
    var roll = random.nextDouble() * total;

    var selected = sessions.last;
    for (var index = 0; index < sessions.length; index++) {
      roll -= weights[index];
      if (roll < 0) {
        selected = sessions[index];
        break;
      }
    }

    final startMinute =
        selected.startedAt.hour * 60 + selected.startedAt.minute;
    final jitter = random.nextInt(jitterMinutes * 2 + 1) - jitterMinutes;
    return startMinute + jitter;
  }

  double _usageWeight(ReminderSession session) {
    final duration = session.endedAt.difference(session.startedAt).inMinutes;
    return (duration / 10).clamp(1, 6).toDouble();
  }
}
