import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:linuxdojo/core/database/tables.dart';
import 'package:linuxdojo/core/models/card_type.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Decks, Cards, Reviews, SessionLogs, Achievements, Settings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
    },
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(
          sessionLogs,
          sessionLogs.multipleChoiceAnswered,
        );
        await migrator.addColumn(
          sessionLogs,
          sessionLogs.multipleChoiceCorrect,
        );
        await migrator.addColumn(
          sessionLogs,
          sessionLogs.bestMultipleChoiceStreak,
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/linuxdojo.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}
