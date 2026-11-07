import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';

import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;
  late SettingsRepository repository;

  setUp(() {
    database = createTestDatabase();
    repository = SettingsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('stores, overwrites, and removes values', () async {
    expect(await repository.get('daily_goal'), isNull);

    await repository.set('daily_goal', '20');
    expect(await repository.get('daily_goal'), '20');

    await repository.set('daily_goal', '30');
    expect(await repository.get('daily_goal'), '30');

    await repository.remove('daily_goal');
    expect(await repository.get('daily_goal'), isNull);
  });

  test('returns all settings as a map', () async {
    await repository.set('experience_level', 'beginner');
    await repository.set('daily_goal', '10');

    expect(await repository.getAll(), {
      'experience_level': 'beginner',
      'daily_goal': '10',
    });
  });
}
