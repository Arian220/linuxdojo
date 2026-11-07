import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/core/theme/app_theme.dart';
import 'package:linuxdojo/features/study/presentation/study_screen.dart';
import 'package:linuxdojo/features/study/presentation/study_session_provider.dart';

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

  testWidgets('flips a card, grades it, and shows the session summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          clockProvider.overrideWithValue(() => DateTime(2026, 3, 1, 10)),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: const StudyScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('What does `pwd` do?'), findsOneWidget);
    expect(find.text('Again'), findsNothing);

    await tester.tap(find.text('What does `pwd` do?'));
    await tester.pumpAndSettle();

    expect(find.text('Prints the current working directory.'), findsOneWidget);
    expect(find.text('pwd'), findsOneWidget);
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(find.text('What does `chmod +x script.sh` do?'), findsOneWidget);

    await tester.tap(find.text('What does `chmod +x script.sh` do?'));
    await tester.pumpAndSettle();
    expect(find.text('Adds execute permission to script.sh.'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(find.text('Session complete'), findsOneWidget);
    expect(find.text('Cards reviewed'), findsOneWidget);
    expect(find.text('Correct answers'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Streak status'), findsOneWidget);
    expect(find.text('Not met'), findsOneWidget);
    expect(find.text('Back to Home'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
