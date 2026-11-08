import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/features/notifications/data/reminder_service.dart';
import 'package:linuxdojo/features/settings/data/notification_permission_service.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/settings/domain/experience_level.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _goals = [10, 20, 30];
  static const _lastStep = 3;

  int _step = 0;
  ExperienceLevel _experienceLevel = ExperienceLevel.beginner;
  int _dailyGoal = SettingsRepository.defaultDailyGoal;
  bool _remindersEnabled = false;
  bool _requestingPermission = false;
  bool _saving = false;

  Future<void> _continue() async {
    if (_step < _lastStep) {
      setState(() => _step++);
      return;
    }

    setState(() => _saving = true);

    try {
      final repository = ref.read(settingsRepositoryProvider);
      await repository.setExperienceLevel(_experienceLevel);
      await repository.setDailyGoal(_dailyGoal);
      await repository.setRemindersEnabled(_remindersEnabled);
      await repository.setOnboardingComplete();
      await ref.read(reminderServiceProvider).sync();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your preferences.')),
      );
    }
  }

  Future<void> _setReminders(bool enabled) async {
    if (!enabled) {
      setState(() => _remindersEnabled = false);
      return;
    }

    setState(() => _requestingPermission = true);
    final granted = await ref
        .read(notificationPermissionServiceProvider)
        .requestPermission();
    if (!mounted) return;

    setState(() {
      _requestingPermission = false;
      _remindersEnabled = granted;
    });

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission is required for reminders.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('LinuxDojo'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                'Step ${_step + 1} of ${_lastStep + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (_step + 1) / (_lastStep + 1),
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(theme),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  if (_step > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => setState(() => _step--),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _continue,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _step == _lastStep
                                  ? 'Start studying'
                                  : 'Continue',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(ThemeData theme) {
    return switch (_step) {
      0 => _StepContent(
        title: 'Choose your level',
        subtitle: 'We use this to tailor your experience. You can change it later in Settings.',
        children: [
          for (final level in ExperienceLevel.values)
            _OptionCard(
              title: level.label,
              subtitle: level.description,
              icon: _levelIcon(level),
              selected: _experienceLevel == level,
              onTap: () => setState(() => _experienceLevel = level),
            ),
        ],
      ),
      1 => _StepContent(
        title: 'Set a daily goal',
        subtitle: 'Your streak counts a day when you review at least this many cards.',
        children: [
          for (final goal in _goals)
            _OptionCard(
              title: '$goal cards',
              subtitle: _goalDescription(goal),
              icon: Icons.flag_outlined,
              selected: _dailyGoal == goal,
              onTap: () => setState(() => _dailyGoal = goal),
            ),
        ],
      ),
      2 => _StepContent(
        title: 'Stay on track',
        subtitle: 'Enable a daily reminder at a smart time based on your study habits. You can change this anytime.',
        children: [
          Material(
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
              value: _remindersEnabled,
              onChanged: _requestingPermission ? null : _setReminders,
              secondary: _requestingPermission
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.notifications_outlined),
              title: const Text('Daily reminders'),
              subtitle: Text(
                _requestingPermission
                    ? 'Requesting notification permission…'
                    : 'One reminder per day at a useful time.',
              ),
            ),
          ),
        ],
      ),
      _ => _StepContent(
        title: 'You’re all set',
        subtitle: 'Your preferences are ready. Time to start practicing.',
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  icon: Icons.signal_cellular_alt,
                  label: 'Experience',
                  value: _experienceLevel.label,
                ),
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.flag_outlined,
                  label: 'Daily goal',
                  value: '$_dailyGoal cards',
                ),
                const Divider(height: 24),
                _SummaryRow(
                  icon: Icons.notifications_outlined,
                  label: 'Reminders',
                  value: _remindersEnabled ? 'On' : 'Off',
                ),
              ],
            ),
          ),
        ],
      ),
    };
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        for (final child in children) ...[child, const SizedBox(height: 12)],
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

IconData _levelIcon(ExperienceLevel level) {
  return switch (level) {
    ExperienceLevel.beginner => Icons.eco_outlined,
    ExperienceLevel.intermediate => Icons.terminal,
    ExperienceLevel.advanced => Icons.engineering_outlined,
  };
}

String _goalDescription(int goal) {
  return switch (goal) {
    10 => 'A light daily habit',
    20 => 'A steady pace',
    _ => 'An ambitious streak',
  };
}
