import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/models/review_thresholds.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/stats/domain/stats_calculator.dart';
import 'package:linuxdojo/features/stats/domain/user_stats.dart';
import 'package:linuxdojo/features/stats/domain/weekly_stats.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';

final statsClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class StatsRepository {
  const StatsRepository(this._database, this._settingsRepository, this._clock);

  final AppDatabase _database;
  final SettingsRepository _settingsRepository;
  final DateTime Function() _clock;

  DateTime now() => _clock();

  Future<UserStats> getUserStats() async {
    final sessions = await _database.select(_database.sessionLogs).get();
    final dailyGoal = await _settingsRepository.getDailyGoal();
    final masteredCards = await _countMasteredCards();
    final totalCards = await _countTotalCards();

    return StatsCalculator.buildUserStats(
      sessions: sessions,
      dailyGoal: dailyGoal,
      masteredCards: masteredCards,
      totalCards: totalCards,
      now: _clock(),
    );
  }

  Stream<int> watchMasteredCards() {
    final count = _database.reviews.cardId.count();
    final query = _database.selectOnly(_database.reviews)
      ..addColumns([count])
      ..where(
        _database.reviews.repetitions.isBiggerOrEqualValue(
          ReviewThresholds.masteredRepetitions,
        ),
      );

    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Stream<int> watchTotalCards() {
    final count = _database.cards.id.count();
    final query = _database.selectOnly(_database.cards)..addColumns([count]);

    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  Future<int> _countMasteredCards() async {
    final count = _database.reviews.cardId.count();
    final query = _database.selectOnly(_database.reviews)
      ..addColumns([count])
      ..where(
        _database.reviews.repetitions.isBiggerOrEqualValue(
          ReviewThresholds.masteredRepetitions,
        ),
      );
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<int> _countTotalCards() async {
    final count = _database.cards.id.count();
    final query = _database.selectOnly(_database.cards)..addColumns([count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }
}

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(settingsRepositoryProvider),
    ref.watch(statsClockProvider),
  );
});

final statsSessionsProvider = StreamProvider<List<SessionLog>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchAllSessions();
});

final statsDailyGoalProvider = StreamProvider<int>((ref) {
  return ref
      .watch(settingsRepositoryProvider)
      .watch(SettingsRepository.dailyGoalKey)
      .map(_parseDailyGoal);
});

final masteredCardsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(statsRepositoryProvider).watchMasteredCards();
});

final totalCardsCountProvider = StreamProvider<int>((ref) {
  return ref.watch(statsRepositoryProvider).watchTotalCards();
});

final userStatsProvider = Provider<AsyncValue<UserStats>>((ref) {
  final sessions = ref.watch(statsSessionsProvider);
  final dailyGoal = ref.watch(statsDailyGoalProvider);
  final masteredCards = ref.watch(masteredCardsCountProvider);
  final totalCards = ref.watch(totalCardsCountProvider);

  if (sessions.hasError) {
    return AsyncError(sessions.error!, sessions.stackTrace ?? StackTrace.empty);
  }
  if (dailyGoal.hasError) {
    return AsyncError(
      dailyGoal.error!,
      dailyGoal.stackTrace ?? StackTrace.empty,
    );
  }
  if (masteredCards.hasError) {
    return AsyncError(
      masteredCards.error!,
      masteredCards.stackTrace ?? StackTrace.empty,
    );
  }
  if (totalCards.hasError) {
    return AsyncError(
      totalCards.error!,
      totalCards.stackTrace ?? StackTrace.empty,
    );
  }

  if (!sessions.hasValue ||
      !dailyGoal.hasValue ||
      !masteredCards.hasValue ||
      !totalCards.hasValue) {
    return const AsyncLoading();
  }

  return AsyncData(
    StatsCalculator.buildUserStats(
      sessions: sessions.requireValue,
      dailyGoal: dailyGoal.requireValue,
      masteredCards: masteredCards.requireValue,
      totalCards: totalCards.requireValue,
      now: ref.watch(statsClockProvider)(),
    ),
  );
});

final weeklyStatsProvider = Provider<AsyncValue<WeeklyStats>>((ref) {
  final sessions = ref.watch(statsSessionsProvider);

  if (sessions.hasError) {
    return AsyncError(sessions.error!, sessions.stackTrace ?? StackTrace.empty);
  }
  if (!sessions.hasValue) {
    return const AsyncLoading();
  }

  return AsyncData(
    StatsCalculator.buildWeeklyStats(
      sessions: sessions.requireValue,
      now: ref.watch(statsClockProvider)(),
    ),
  );
});

int _parseDailyGoal(String? raw) {
  final parsed = int.tryParse(raw ?? '');
  return parsed != null && parsed > 0
      ? parsed
      : SettingsRepository.defaultDailyGoal;
}
