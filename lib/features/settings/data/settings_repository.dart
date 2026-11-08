import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/features/settings/domain/app_settings.dart';
import 'package:linuxdojo/features/settings/domain/experience_level.dart';
import 'package:linuxdojo/features/settings/domain/settings_keys.dart';

class SettingsRepository {
  const SettingsRepository(this._database);

  static const dailyGoalKey = SettingsKeys.dailyGoal;
  static const defaultDailyGoal = AppSettings.defaultDailyGoal;

  final AppDatabase _database;

  Future<AppSettings> getAppSettings() async {
    return AppSettings.fromMap(await getAll());
  }

  Stream<AppSettings> watchAppSettings() {
    return _database.select(_database.settings).watch().map((rows) {
      return AppSettings.fromMap({for (final row in rows) row.key: row.value});
    });
  }

  Future<int> getDailyGoal() async {
    final raw = await get(dailyGoalKey);
    final parsed = int.tryParse(raw ?? '');
    return parsed != null && parsed > 0 ? parsed : defaultDailyGoal;
  }

  Future<String?> get(String key) async {
    final query = _database.select(_database.settings)
      ..where((setting) => setting.key.equals(key));
    final setting = await query.getSingleOrNull();
    return setting?.value;
  }

  Stream<String?> watch(String key) {
    final query = _database.select(_database.settings)
      ..where((setting) => setting.key.equals(key));
    return query.watchSingleOrNull().map((setting) => setting?.value);
  }

  Future<Map<String, String>> getAll() async {
    final rows = await _database.select(_database.settings).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> set(String key, String value) {
    return _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(key: key, value: value),
        );
  }

  Future<void> setExperienceLevel(ExperienceLevel level) {
    return set(SettingsKeys.experienceLevel, level.value);
  }

  Future<void> setDailyGoal(int goal) {
    return set(SettingsKeys.dailyGoal, '$goal');
  }

  Future<void> setRemindersEnabled(bool enabled) {
    return set(SettingsKeys.remindersEnabled, enabled ? 'true' : 'false');
  }

  Future<void> setOnboardingComplete() {
    return set(SettingsKeys.onboardingComplete, 'true');
  }

  Future<void> resetProgress() {
    return _database.transaction(() async {
      await _database.delete(_database.reviews).go();
      await _database.delete(_database.sessionLogs).go();
      await _database.delete(_database.achievements).go();
    });
  }

  Future<void> remove(String key) {
    final query = _database.delete(_database.settings)
      ..where((setting) => setting.key.equals(key));
    return query.go();
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});

final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchAppSettings();
});
