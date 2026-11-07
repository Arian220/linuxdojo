import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';

class SettingsRepository {
  const SettingsRepository(this._database);

  final AppDatabase _database;

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

  Future<void> remove(String key) {
    final query = _database.delete(_database.settings)
      ..where((setting) => setting.key.equals(key));
    return query.go();
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(appDatabaseProvider));
});
