import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/app/app.dart';
import 'package:linuxdojo/core/database/database_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(databaseSeedProvider.future);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LinuxDojoApp(),
    ),
  );
}
