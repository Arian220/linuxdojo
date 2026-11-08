import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/theme/app_typography.dart';
import 'package:linuxdojo/core/widgets/linuxdojo_app_bar.dart';
import 'package:linuxdojo/features/notifications/data/reminder_service.dart';
import 'package:linuxdojo/features/settings/data/notification_permission_service.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/settings/domain/app_settings.dart';
import 'package:linuxdojo/features/settings/domain/experience_level.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: const LinuxDojoAppBar(
        title: 'Settings',
        icon: Icons.settings_outlined,
      ),
      body: SafeArea(
        child: settings.when(
          data: (settings) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const _SectionHeader('Study preferences'),
              _SettingsTile(
                icon: Icons.signal_cellular_alt,
                title: 'Experience level',
                subtitle: settings.experienceLevel.label,
                onTap: () => _chooseExperienceLevel(settings),
              ),
              _SettingsTile(
                icon: Icons.flag_outlined,
                title: 'Daily goal',
                subtitle: '${settings.dailyGoal} cards per day',
                onTap: () => _chooseDailyGoal(settings),
              ),
              _ReminderTile(enabled: settings.remindersEnabled),
              const SizedBox(height: 24),
              const _SectionHeader('Data'),
              _SettingsTile(
                icon: Icons.delete_outline,
                title: 'Reset progress',
                subtitle: 'Clear reviews, sessions, streaks, and achievements',
                color: Theme.of(context).colorScheme.error,
                onTap: _confirmReset,
              ),
              const SizedBox(height: 24),
              const _SectionHeader('About'),
              const _SettingsTile(
                icon: Icons.info_outline,
                title: 'LinuxDojo',
                subtitle:
                    'Offline Linux command flashcards with spaced repetition.',
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: 'MIT License',
                subtitle: 'Open source license',
                onTap: _showLicense,
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _SettingsError(
            onRetry: () => ref.invalidate(appSettingsProvider),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseExperienceLevel(AppSettings settings) async {
    final selected = await showDialog<ExperienceLevel>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Experience level'),
        children: [
          for (final level in ExperienceLevel.values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(level),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(level.label),
                        const SizedBox(height: 2),
                        Text(
                          level.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (settings.experienceLevel == level)
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
        ],
      ),
    );

    if (selected == null) return;
    await ref.read(settingsRepositoryProvider).setExperienceLevel(selected);
  }

  Future<void> _chooseDailyGoal(AppSettings settings) async {
    const goals = [10, 20, 30];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Daily goal'),
        children: [
          for (final goal in goals)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(goal),
              child: Row(
                children: [
                  Expanded(child: Text('$goal cards per day')),
                  if (settings.dailyGoal == goal)
                    Icon(
                      Icons.check_circle,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
        ],
      ),
    );

    if (selected == null) return;
    await ref.read(settingsRepositoryProvider).setDailyGoal(selected);
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This permanently clears your reviews, session history, streaks, '
            'and achievements. Your decks and preferences stay.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(64, 52),
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(settingsRepositoryProvider).resetProgress();
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Progress reset.')));
  }

  void _showLicense() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MIT License'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              _mitLicense,
              style: AppTypography.command.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ReminderTile extends ConsumerStatefulWidget {
  const _ReminderTile({required this.enabled});

  final bool enabled;

  @override
  ConsumerState<_ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends ConsumerState<_ReminderTile> {
  bool _busy = false;

  Future<void> _onChanged(bool enabled) async {
    if (!enabled) {
      await _save(false);
      return;
    }

    setState(() => _busy = true);
    final granted = await ref
        .read(notificationPermissionServiceProvider)
        .requestPermission();
    if (!mounted) return;

    setState(() => _busy = false);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission is required for reminders.'),
        ),
      );
      return;
    }

    await _save(true);
  }

  Future<void> _save(bool enabled) async {
    try {
      await ref.read(settingsRepositoryProvider).setRemindersEnabled(enabled);
      await ref.read(reminderServiceProvider).sync();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save reminder setting.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          value: widget.enabled,
          onChanged: _busy ? null : _onChanged,
          secondary: _busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.notifications_outlined),
          title: const Text('Reminders'),
          subtitle: Text(
            _busy
                ? 'Requesting notification permission…'
                : 'Daily reminder at a smart time based on your study habits.',
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = color ?? theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: theme.colorScheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color ?? theme.colorScheme.secondary),
          title: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: onTap == null
              ? null
              : Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 36, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Could not load settings',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

const _mitLicense = '''
MIT License

Copyright (c) 2026 LinuxDojo contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
''';
