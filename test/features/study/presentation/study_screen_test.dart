import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/database/seed/database_seeder.dart';
import 'package:linuxdojo/core/theme/app_theme.dart';
import 'package:linuxdojo/features/study/presentation/study_screen.dart';
import 'package:linuxdojo/features/study/presentation/study_session_provider.dart';
import 'package:linuxdojo/features/study/presentation/widgets/flip_card.dart';
import 'package:linuxdojo/features/study/presentation/widgets/multiple_choice_card.dart';

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

  Future<void> pumpStudyScreen(WidgetTester tester) async {
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
  }

  testWidgets('runs a mixed session with flip and multiple choice cards', (
    tester,
  ) async {
    await pumpStudyScreen(tester);

    var sawFlip = false;
    var sawMultipleChoice = false;

    for (var index = 0; index < 8; index++) {
      final flipFinder = find.byType(FlipCard);
      final multipleChoiceFinder = find.byType(MultipleChoiceCard);

      if (flipFinder.evaluate().isNotEmpty) {
        sawFlip = true;
        final flip = tester.widget<FlipCard>(flipFinder);

        expect(find.text(flip.card.prompt), findsOneWidget);
        expect(find.text('Again'), findsNothing);

        await tester.tap(find.text(flip.card.prompt));
        await tester.pumpAndSettle();

        expect(find.text(flip.card.answer), findsOneWidget);
        expect(find.text(flip.card.example), findsOneWidget);
        expect(find.text('Again'), findsOneWidget);
        expect(find.text('Hard'), findsOneWidget);
        expect(find.text('Good'), findsOneWidget);
        expect(find.text('Easy'), findsOneWidget);

        await tester.tap(find.text('Good'));
        await tester.pumpAndSettle();
      } else {
        expect(multipleChoiceFinder, findsOneWidget);
        sawMultipleChoice = true;
        final multipleChoice = tester.widget<MultipleChoiceCard>(
          multipleChoiceFinder,
        );

        expect(find.text(multipleChoice.studyCard.card.prompt), findsOneWidget);
        expect(multipleChoice.studyCard.options, hasLength(4));
        expect(multipleChoice.studyCard.options.toSet(), hasLength(4));

        await tester.tap(find.text(multipleChoice.studyCard.card.answer));
        await tester.pumpAndSettle();

        expect(find.text('Correct'), findsOneWidget);
        expect(
          find.text('Answer: ${multipleChoice.studyCard.card.answer}'),
          findsOneWidget,
        );
        expect(
          find.text(multipleChoice.studyCard.card.example),
          findsOneWidget,
        );
        expect(find.text('Continue'), findsOneWidget);

        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
      }
    }

    expect(sawFlip, isTrue);
    expect(sawMultipleChoice, isTrue);
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
    await pumpStudyScreen(tester);

    for (var index = 0; index < 8; index++) {
      final flipFinder = find.byType(FlipCard);

      if (flipFinder.evaluate().isNotEmpty) {
        final flip = tester.widget<FlipCard>(flipFinder);

        await tester.tap(find.text(flip.card.prompt));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Good'));
        await tester.pumpAndSettle();
        continue;
      }

      final multipleChoice = tester.widget<MultipleChoiceCard>(
        find.byType(MultipleChoiceCard),
      );
      final wrongLabel = multipleChoice.studyCard.options.firstWhere(
        (option) => option != multipleChoice.studyCard.card.answer,
      );

      await tester.tap(find.widgetWithText(OutlinedButton, wrongLabel));
      await tester.pumpAndSettle();

      expect(find.text('Not quite'), findsOneWidget);
      expect(
        find.text('Answer: ${multipleChoice.studyCard.card.answer}'),
        findsOneWidget,
      );
      expect(find.text(multipleChoice.studyCard.card.example), findsOneWidget);
      break;
    }

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
