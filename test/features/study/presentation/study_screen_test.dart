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

  testWidgets('runs a mixed session with flip and multiple choice cards', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
    expect(find.text('Again'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('Good'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);

    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(
      find.text('Which command lists directory contents?'),
      findsOneWidget,
    );
    expect(find.text('Again'), findsNothing);

    await tester.tap(find.text('ls'));
    await tester.pumpAndSettle();

    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Answer: ls'), findsOneWidget);
    expect(find.text('ls -la'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What does `cd /tmp` do?'), findsOneWidget);
    await tester.tap(find.text('What does `cd /tmp` do?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(find.text('Which command creates a directory?'), findsOneWidget);
    await tester.tap(find.text('mkdir'));
    await tester.pumpAndSettle();
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('mkdir notes'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(
      find.text('Which command searches text for a pattern?'),
      findsOneWidget,
    );
    await tester.tap(find.text('grep'));
    await tester.pumpAndSettle();
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('grep -r TODO .'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('What does `ls -l` do?'), findsOneWidget);
    await tester.tap(find.text('What does `ls -l` do?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(find.text('Which command creates an empty file?'), findsOneWidget);
    await tester.tap(find.text('touch'));
    await tester.pumpAndSettle();
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('touch notes.txt'), findsOneWidget);
    await tester.tap(find.text('Continue'));
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

  testWidgets('shows feedback and the example for a wrong MC answer', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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

    await tester.tap(find.text('What does `pwd` do?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Good'));
    await tester.pumpAndSettle();

    expect(
      find.text('Which command lists directory contents?'),
      findsOneWidget,
    );

    final wrongLabel = find
        .byType(OutlinedButton)
        .evaluate()
        .map(
          (element) => ((element.widget as OutlinedButton).child as Text).data,
        )
        .firstWhere((label) => label != 'ls');

    await tester.tap(find.widgetWithText(OutlinedButton, wrongLabel!));
    await tester.pumpAndSettle();

    expect(find.text('Not quite'), findsOneWidget);
    expect(find.text('Answer: ls'), findsOneWidget);
    expect(find.text('ls -la'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
