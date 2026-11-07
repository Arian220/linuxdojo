import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/core/database/seed/seed_source.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final databaseSeederProvider = Provider<DatabaseSeeder>((ref) {
  return const DatabaseSeeder(AssetSeedSource());
});

final databaseSeedProvider = FutureProvider<SeedResult>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ref.watch(databaseSeederProvider).seedIfEmpty(database);
});
