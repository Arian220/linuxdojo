import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/core/theme/app_theme.dart';
import 'package:linuxdojo/features/decks/presentation/decks_screen.dart';

import '../../../helpers/fake_seed_source.dart';
import '../../../helpers/sample_seed_data.dart';
import '../../../helpers/test_database.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = createTestDatabase();
    await const DatabaseSeeder(FakeSeedSource(sampleDecks))
        .seedIfEmpty(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpDecks(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.dark, home: const DecksScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('lists every deck with card count and mastery progress', (
    tester,
  ) async {
    await pumpDecks(tester);

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Essential terminal commands.'), findsOneWidget);
    expect(find.text('7 cards'), findsOneWidget);
    expect(find.text('0 / 7 mastered'), findsOneWidget);

    expect(find.text('Permissions'), findsOneWidget);
    expect(find.text('1 card'), findsOneWidget);
    expect(find.text('0 / 1 mastered'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('opens a read-only card list for the selected deck', (
    tester,
  ) async {
    await pumpDecks(tester);

    await tester.tap(find.text('Basics'));
    await tester.pumpAndSettle();

    expect(find.text('Essential terminal commands.'), findsOneWidget);
    expect(find.text('0 of 7 mastered'), findsOneWidget);
    expect(find.text('What does `pwd` do?'), findsOneWidget);
    expect(
      find.text('Which command lists directory contents?'),
      findsOneWidget,
    );
    expect(find.text('What does `cd /tmp` do?'), findsOneWidget);
    expect(find.text('Which command creates a directory?'), findsOneWidget);
    expect(
      find.text('Which command searches text for a pattern?'),
      findsOneWidget,
    );
    expect(find.text('What does `ls -l` do?'), findsOneWidget);
    expect(find.text('Which command creates an empty file?'), findsOneWidget);

    expect(find.text('Novice'), findsNWidgets(5));
    expect(find.text('User'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
