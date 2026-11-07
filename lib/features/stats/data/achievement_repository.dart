import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';

class AchievementRepository {
  const AchievementRepository(this._database);

  final AppDatabase _database;

  Future<List<Achievement>> getAchievements() {
    final query = _database.select(_database.achievements)
      ..orderBy([(achievement) => OrderingTerm.asc(achievement.id)]);
    return query.get();
  }

  Stream<List<Achievement>> watchAchievements() {
    final query = _database.select(_database.achievements)
      ..orderBy([(achievement) => OrderingTerm.asc(achievement.id)]);
    return query.watch();
  }

  Future<bool> isUnlocked(String id) async {
    final query = _database.select(_database.achievements)
      ..where((achievement) => achievement.id.equals(id));
    final achievement = await query.getSingleOrNull();
    return achievement?.unlockedAt != null;
  }

  Future<void> unlock(String id, {DateTime? at}) {
    return _database
        .into(_database.achievements)
        .insertOnConflictUpdate(
          AchievementsCompanion.insert(
            id: id,
            unlockedAt: Value(at ?? DateTime.now()),
          ),
        );
  }
}

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository(ref.watch(appDatabaseProvider));
});
