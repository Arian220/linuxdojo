import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linuxdojo/app/app.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/database/database_provider.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = createTestDatabase();
  });

  tearDown(() async {
    await database.close();
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const LinuxDojoApp(),
    );
  }

  testWidgets('starts on Home with the dark theme', (tester) async {
    await tester.pumpWidget(buildApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.theme?.brightness, Brightness.dark);

    final navigationBar = tester.widget<NavigationBar>(
      find.byType(NavigationBar),
    );
    expect(navigationBar.selectedIndex, 0);
    expect(navigationBar.destinations, hasLength(4));

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('bottom navigation switches tabs', (tester) async {
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byIcon(Icons.layers_outlined));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );

    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      2,
    );

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      3,
    );

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
