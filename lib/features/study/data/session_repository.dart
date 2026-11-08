import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';

class SessionRepository {
  const SessionRepository(this._database);

  final AppDatabase _database;

  Future<int> recordSession({
    required DateTime startedAt,
    required DateTime endedAt,
    required int cardsReviewed,
    required int correctAnswers,
    int multipleChoiceAnswered = 0,
    int multipleChoiceCorrect = 0,
    int bestMultipleChoiceStreak = 0,
  }) {
    return _database
        .into(_database.sessionLogs)
        .insert(
          SessionLogsCompanion.insert(
            startedAt: startedAt,
            endedAt: endedAt,
            cardsReviewed: Value(cardsReviewed),
            correctAnswers: Value(correctAnswers),
            multipleChoiceAnswered: Value(multipleChoiceAnswered),
            multipleChoiceCorrect: Value(multipleChoiceCorrect),
            bestMultipleChoiceStreak: Value(bestMultipleChoiceStreak),
          ),
        );
  }

  Future<List<SessionLog>> getSessions({int limit = 30}) {
    final query = _database.select(_database.sessionLogs)
      ..orderBy([(session) => OrderingTerm.desc(session.startedAt)])
      ..limit(limit);
    return query.get();
  }

  Stream<List<SessionLog>> watchSessions({int limit = 30}) {
    final query = _database.select(_database.sessionLogs)
      ..orderBy([(session) => OrderingTerm.desc(session.startedAt)])
      ..limit(limit);
    return query.watch();
  }

  Future<List<SessionLog>> getAllSessions() {
    final query = _database.select(_database.sessionLogs)
      ..orderBy([(session) => OrderingTerm.asc(session.startedAt)]);
    return query.get();
  }

  Stream<List<SessionLog>> watchAllSessions() {
    final query = _database.select(_database.sessionLogs)
      ..orderBy([(session) => OrderingTerm.asc(session.startedAt)]);
    return query.watch();
  }

  Future<List<SessionLog>> getSessionsSince(DateTime since) {
    final query = _database.select(_database.sessionLogs)
      ..where((session) => session.startedAt.isBiggerOrEqualValue(since))
      ..orderBy([(session) => OrderingTerm.asc(session.startedAt)]);
    return query.get();
  }
}

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(appDatabaseProvider));
});
