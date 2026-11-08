import 'package:flutter/material.dart';
import 'package:linuxdojo/core/theme/app_colors.dart';
import 'package:linuxdojo/core/widgets/linuxdojo_app_bar.dart';
import 'package:linuxdojo/features/study/presentation/study_session_state.dart';

class SessionSummaryScreen extends StatelessWidget {
  const SessionSummaryScreen({required this.summary, super.key});

  final StudySessionSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const LinuxDojoAppBar(
        title: 'Summary',
        icon: Icons.check_circle_outline,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Icon(
                        Icons.check_circle_outline,
                        size: 56,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Session complete',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your reviews are scheduled for the next session.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _StatTile(
                              label: 'Cards reviewed',
                              value: '${summary.cardsReviewed}',
                              subtitle: 'this session',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatTile(
                              label: 'Correct answers',
                              value: '${summary.correctAnswers}',
                              subtitle: 'of ${summary.cardsReviewed} reviewed',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _StatTile(
                              label: 'Time',
                              value: _formatDuration(summary.elapsed),
                              subtitle: 'session time',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatTile(
                              label: 'Streak status',
                              value: summary.dailyGoalMet ? 'Met' : 'Not met',
                              valueColor: summary.dailyGoalMet
                                  ? AppColors.success
                                  : AppColors.warning,
                              subtitle:
                                  '${summary.dailyCards} / ${summary.dailyGoal} cards today',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds}s';
  }
  return '${seconds}s';
}
