import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/features/notifications/data/reminder_service.dart';
import 'package:linuxdojo/features/stats/data/achievement_service.dart';

final appStartupProvider = FutureProvider<void>((ref) async {
  final achievementService = ref.watch(achievementServiceProvider);
  final reminderService = ref.watch(reminderServiceProvider);
  await ref.watch(databaseSeedProvider.future);

  try {
    await achievementService.sync();
  } catch (_) {}

  try {
    await reminderService.sync();
  } catch (_) {}
});
