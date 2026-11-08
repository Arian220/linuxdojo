import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/theme/app_colors.dart';
import 'package:linuxdojo/core/widgets/linuxdojo_app_bar.dart';
import 'package:linuxdojo/features/stats/data/achievement_service.dart';
import 'package:linuxdojo/features/stats/data/stats_repository.dart';
import 'package:linuxdojo/features/stats/domain/achievement.dart';
import 'package:linuxdojo/features/stats/domain/user_stats.dart';
import 'package:linuxdojo/features/stats/domain/weekly_stats.dart';
import 'package:linuxdojo/features/stats/presentation/achievements_screen.dart';
import 'package:linuxdojo/features/study/presentation/study_session_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(userStatsProvider);
    final weekly = ref.watch(weeklyStatsProvider);
    final achievements = ref.watch(achievementStatusProvider);
    final dueCards = ref.watch(dueCardsProvider);

    return Scaffold(
      appBar: const LinuxDojoAppBar(
        title: 'Stats',
        icon: Icons.insights_outlined,
      ),
      body: SafeArea(
        child: stats.when(
          data: (stats) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _StreakCard(stats: stats),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(
                      label: 'Mastered',
                      value: '${stats.masteredCards}',
                      icon: Icons.school_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      label: 'Due today',
                      value: dueCards.hasValue
                          ? '${dueCards.value!.length}'
                          : '—',
                      icon: Icons.today_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      label: 'Sessions',
                      value: '${stats.totalSessions}',
                      icon: Icons.history,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _WeeklyChartCard(weekly: weekly),
              const SizedBox(height: 24),
              _AchievementsLink(
                achievements: achievements,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AchievementsScreen(),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _StatsError(
            onRetry: () {
              ref.invalidate(statsSessionsProvider);
              ref.invalidate(statsDailyGoalProvider);
              ref.invalidate(masteredCardsCountProvider);
              ref.invalidate(totalCardsCountProvider);
            },
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.stats});

  final UserStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                size: 36,
                color: stats.currentStreak > 0
                    ? AppColors.warning
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${stats.currentStreak} day streak',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stats.cardsReviewedToday} / ${stats.dailyGoal} cards today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                stats.dailyGoalMet ? 'Goal met' : '',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.dailyGoalProgress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: stats.dailyGoalMet
                  ? AppColors.success
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                'Longest: ${stats.longestStreak} days',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                'Goals met: ${stats.daysGoalMet}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.secondary),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({required this.weekly});

  final AsyncValue<WeeklyStats> weekly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Last 7 days',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const _LegendDot(color: AppColors.primary, label: 'Reviewed'),
              const SizedBox(width: 12),
              const _LegendDot(color: AppColors.secondary, label: 'Correct'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: weekly.when(
              data: (weekly) => _WeeklyBarChart(weekly: weekly),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Could not load weekly activity.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.weekly});

  final WeeklyStats weekly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = weekly.days.fold<int>(
      0,
      (maxValue, day) =>
          max(maxValue, max(day.cardsReviewed, day.correctAnswers)),
    );
    final maxY = max(4.0, (maxValue * 1.2).ceilToDouble());
    final interval = maxY <= 4 ? 1.0 : (maxY / 4).ceilToDouble();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: theme.colorScheme.outlineVariant, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: interval,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 26,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= weekly.days.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _weekdayLabel(weekly.days[index].date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(enabled: false),
        barGroups: List<BarChartGroupData>.generate(weekly.days.length, (
          index,
        ) {
          final day = weekly.days[index];
          return BarChartGroupData(
            x: index,
            barsSpace: 3,
            barRods: [
              BarChartRodData(
                toY: day.cardsReviewed.toDouble(),
                color: AppColors.primary,
                width: 8,
                borderRadius: BorderRadius.circular(3),
              ),
              BarChartRodData(
                toY: day.correctAnswers.toDouble(),
                color: AppColors.secondary,
                width: 8,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _AchievementsLink extends StatelessWidget {
  const _AchievementsLink({required this.achievements, required this.onTap});

  final AsyncValue<List<AchievementStatus>> achievements;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = achievements.value
        ?.where((item) => item.isUnlocked)
        .length;
    final total = achievements.value?.length ?? achievementDefinitions.length;
    final progress = total == 0 ? 0.0 : (unlocked ?? 0) / total;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unlocked == null
                          ? 'Loading progress…'
                          : '$unlocked of $total unlocked',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.onRetry});

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
              'Could not load stats',
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

String _weekdayLabel(DateTime date) {
  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return labels[date.weekday - 1];
}
