import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/features/notifications/domain/smart_reminder.dart';

void main() {
  const reminder = SmartReminder();
  final now = DateTime(2026, 11, 7, 12);

  ReminderSession session(
    DateTime startedAt, {
    Duration duration = const Duration(minutes: 10),
  }) {
    return ReminderSession(
      startedAt: startedAt,
      endedAt: startedAt.add(duration),
    );
  }

  test('falls back to 19:00 when there is no session history', () {
    final plan = reminder.nextReminder(
      sessions: const [],
      currentStreak: 0,
      dailyGoal: 10,
      now: now,
      random: Random(1),
    );

    expect(plan.usedFallback, isTrue);
    expect(plan.scheduledAt, DateTime(2026, 11, 7, 19));
  });

  test('moves the fallback reminder to tomorrow when today is past', () {
    final plan = reminder.nextReminder(
      sessions: const [],
      currentStreak: 0,
      dailyGoal: 10,
      now: DateTime(2026, 11, 7, 20),
      random: Random(1),
    );

    expect(plan.scheduledAt, DateTime(2026, 11, 8, 19));
  });

  test('keeps reminders inside the waking window', () {
    final plan = reminder.nextReminder(
      sessions: [session(DateTime(2026, 11, 6, 23))],
      currentStreak: 4,
      dailyGoal: 10,
      now: now,
      random: Random(4),
    );

    final minutes = plan.scheduledAt.hour * 60 + plan.scheduledAt.minute;
    expect(minutes, greaterThanOrEqualTo(7 * 60));
    expect(minutes, lessThan(22 * 60));
  });

  test('only samples around observed study times', () {
    final sessions = [
      session(DateTime(2026, 11, 1, 8)),
      session(DateTime(2026, 11, 3, 8, 10)),
      session(DateTime(2026, 11, 6, 8, 5)),
    ];

    for (var seed = 0; seed < 100; seed++) {
      final plan = reminder.nextReminder(
        sessions: sessions,
        currentStreak: 3,
        dailyGoal: 10,
        now: now,
        random: Random(seed),
      );

      expect(plan.scheduledAt.hour, inInclusiveRange(7, 8));
    }
  });

  test('ignores sessions outside the history window', () {
    final sessions = [
      session(DateTime(2026, 8, 1, 8)),
      session(DateTime(2026, 11, 6, 20)),
    ];

    for (var seed = 0; seed < 50; seed++) {
      final plan = reminder.nextReminder(
        sessions: sessions,
        currentStreak: 2,
        dailyGoal: 10,
        now: now,
        random: Random(seed),
      );

      expect(plan.scheduledAt.hour, inInclusiveRange(19, 20));
    }
  });

  test('weights longer app usage sessions more heavily', () {
    final sessions = [
      session(DateTime(2026, 11, 6, 8), duration: const Duration(minutes: 5)),
      session(DateTime(2026, 11, 6, 20), duration: const Duration(minutes: 60)),
    ];

    var morning = 0;
    var evening = 0;

    for (var seed = 0; seed < 100; seed++) {
      final plan = reminder.nextReminder(
        sessions: sessions,
        currentStreak: 2,
        dailyGoal: 10,
        now: now,
        random: Random(seed),
      );

      if (plan.scheduledAt.hour < 12) {
        morning++;
      } else {
        evening++;
      }
    }

    expect(evening, greaterThan(morning));
  });

  test('uses the same time for the same random seed', () {
    final sessions = [session(DateTime(2026, 11, 6, 18))];

    final first = reminder.nextReminder(
      sessions: sessions,
      currentStreak: 2,
      dailyGoal: 10,
      now: now,
      random: Random(7),
    );
    final second = reminder.nextReminder(
      sessions: sessions,
      currentStreak: 2,
      dailyGoal: 10,
      now: now,
      random: Random(7),
    );

    expect(first.scheduledAt, second.scheduledAt);
  });

  test('reminds earlier for a larger daily goal', () {
    final sessions = [session(DateTime(2026, 11, 6, 19))];

    final lightGoal = reminder.nextReminder(
      sessions: sessions,
      currentStreak: 2,
      dailyGoal: 10,
      now: now,
      random: Random(3),
    );
    final heavyGoal = reminder.nextReminder(
      sessions: sessions,
      currentStreak: 2,
      dailyGoal: 30,
      now: now,
      random: Random(3),
    );

    expect(
      heavyGoal.scheduledAt.difference(lightGoal.scheduledAt),
      const Duration(minutes: -30),
    );
  });

  test('reminds earlier after a broken streak', () {
    final sessions = [session(DateTime(2026, 11, 6, 19))];

    final broken = reminder.nextReminder(
      sessions: sessions,
      currentStreak: 0,
      dailyGoal: 10,
      now: now,
      random: Random(9),
    );
    final active = reminder.nextReminder(
      sessions: sessions,
      currentStreak: 5,
      dailyGoal: 10,
      now: now,
      random: Random(9),
    );

    expect(
      broken.scheduledAt.difference(active.scheduledAt),
      const Duration(minutes: -15),
    );
  });

  test('honors a custom waking window', () {
    const customReminder = SmartReminder(
      window: ReminderWindow(startHour: 9, endHour: 17),
    );
    final plan = customReminder.nextReminder(
      sessions: [session(DateTime(2026, 11, 6, 21))],
      currentStreak: 2,
      dailyGoal: 10,
      now: now,
      random: Random(2),
    );

    final minutes = plan.scheduledAt.hour * 60 + plan.scheduledAt.minute;
    expect(minutes, greaterThanOrEqualTo(9 * 60));
    expect(minutes, lessThan(17 * 60));
  });
}
