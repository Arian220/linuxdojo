import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/features/stats/data/achievement_repository.dart';
import 'package:linuxdojo/features/stats/data/stats_repository.dart';
import 'package:linuxdojo/features/stats/domain/achievement.dart';

class AchievementService {
  const AchievementService(this._statsRepository, this._achievementRepository);

  final StatsRepository _statsRepository;
  final AchievementRepository _achievementRepository;

  Future<List<AchievementStatus>> sync() async {
    final stats = await _statsRepository.getUserStats();
    final existing = await _achievementRepository.getAchievements();
    final unlockedAt = <String, DateTime>{
      for (final achievement in existing)
        if (achievement.unlockedAt != null)
          achievement.id: achievement.unlockedAt!,
    };
    final now = _statsRepository.now();

    for (final definition in achievementDefinitions) {
      if (unlockedAt.containsKey(definition.id)) continue;
      if (!definition.isUnlocked(stats)) continue;

      await _achievementRepository.unlock(definition.id, at: now);
      unlockedAt[definition.id] = now;
    }

    return _buildStatuses(unlockedAt);
  }
}

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService(
    ref.watch(statsRepositoryProvider),
    ref.watch(achievementRepositoryProvider),
  );
});

final achievementStatusProvider = StreamProvider<List<AchievementStatus>>((
  ref,
) {
  return ref
      .watch(achievementRepositoryProvider)
      .watchAchievements()
      .map(_buildStatusesFromRows);
});

List<AchievementStatus> _buildStatusesFromRows(List<Achievement> achievements) {
  final unlockedAt = <String, DateTime>{
    for (final achievement in achievements)
      if (achievement.unlockedAt != null)
        achievement.id: achievement.unlockedAt!,
  };
  return _buildStatuses(unlockedAt);
}

List<AchievementStatus> _buildStatuses(Map<String, DateTime> unlockedAt) {
  return achievementDefinitions
      .map(
        (definition) => AchievementStatus(
          definition: definition,
          unlockedAt: unlockedAt[definition.id],
        ),
      )
      .toList(growable: false);
}
