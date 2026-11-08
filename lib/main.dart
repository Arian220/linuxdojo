import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/app/app.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/features/stats/data/achievement_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  await container.read(databaseSeedProvider.future);
  try {
    await container.read(achievementServiceProvider).sync();
  } catch (_) {}

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const LinuxDojoApp(),
    ),
  );
}
