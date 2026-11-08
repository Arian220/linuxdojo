import 'package:linuxdojo/features/settings/domain/experience_level.dart';
import 'package:linuxdojo/features/settings/domain/settings_keys.dart';

class AppSettings {
  const AppSettings({
    required this.experienceLevel,
    required this.dailyGoal,
    required this.remindersEnabled,
    required this.onboardingCompleted,
  });

  static const defaultDailyGoal = 10;

  static const defaults = AppSettings(
    experienceLevel: ExperienceLevel.beginner,
    dailyGoal: defaultDailyGoal,
    remindersEnabled: false,
    onboardingCompleted: false,
  );

  final ExperienceLevel experienceLevel;
  final int dailyGoal;
  final bool remindersEnabled;
  final bool onboardingCompleted;

  factory AppSettings.fromMap(Map<String, String> values) {
    final dailyGoal = int.tryParse(values[SettingsKeys.dailyGoal] ?? '');

    return AppSettings(
      experienceLevel: ExperienceLevel.fromValue(
        values[SettingsKeys.experienceLevel],
      ),
      dailyGoal: dailyGoal != null && dailyGoal > 0
          ? dailyGoal
          : defaultDailyGoal,
      remindersEnabled: values[SettingsKeys.remindersEnabled] == 'true',
      onboardingCompleted: values[SettingsKeys.onboardingComplete] == 'true',
    );
  }
}
