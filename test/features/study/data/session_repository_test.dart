import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/features/study/data/session_repository.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late SessionRepository repository;

  setUp(() {
    database = createTestDatabase();
    repository = SessionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('records and reads a completed session', () async {
    final startedAt = DateTime(2026, 1, 10, 9);
    final endedAt = startedAt.add(const Duration(minutes: 12));

    final id = await repository.recordSession(
      startedAt: startedAt,
      endedAt: endedAt,
      cardsReviewed: 20,
      correctAnswers: 16,
      multipleChoiceAnswered: 8,
      multipleChoiceCorrect: 6,
      bestMultipleChoiceStreak: 4,
    );

    final sessions = await repository.getSessions();

    expect(sessions, hasLength(1));
    expect(sessions.single.id, id);
    expect(sessions.single.cardsReviewed, 20);
    expect(sessions.single.correctAnswers, 16);
    expect(sessions.single.multipleChoiceAnswered, 8);
    expect(sessions.single.multipleChoiceCorrect, 6);
    expect(sessions.single.bestMultipleChoiceStreak, 4);
  });

  test('filters sessions by start date', () async {
    await repository.recordSession(
      startedAt: DateTime(2026, 1, 1),
      endedAt: DateTime(2026, 1, 1, 0, 10),
      cardsReviewed: 10,
      correctAnswers: 8,
    );
    await repository.recordSession(
      startedAt: DateTime(2026, 1, 8),
      endedAt: DateTime(2026, 1, 8, 0, 10),
      cardsReviewed: 12,
      correctAnswers: 10,
    );

    final sessions = await repository.getSessionsSince(DateTime(2026, 1, 5));

    expect(sessions, hasLength(1));
    expect(sessions.single.cardsReviewed, 12);
  });
}
