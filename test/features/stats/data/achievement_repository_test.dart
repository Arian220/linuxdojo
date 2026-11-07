import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/features/stats/data/achievement_repository.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late AchievementRepository repository;

  setUp(() {
    database = createTestDatabase();
    repository = AchievementRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('unlocks achievements once and keeps the timestamp', () async {
    expect(await repository.getAchievements(), isEmpty);
    expect(await repository.isUnlocked('first_session'), isFalse);

    final unlockedAt = DateTime(2026, 2, 1, 18, 30);
    await repository.unlock('first_session', at: unlockedAt);

    expect(await repository.isUnlocked('first_session'), isTrue);
    expect(await repository.isUnlocked('other'), isFalse);

    final achievements = await repository.getAchievements();
    expect(achievements, hasLength(1));
    expect(achievements.single.id, 'first_session');
    expect(achievements.single.unlockedAt, unlockedAt);
  });
}
