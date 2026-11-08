import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/widgets/linuxdojo_app_bar.dart';
import 'package:linuxdojo/features/stats/data/achievement_service.dart';
import 'package:linuxdojo/features/stats/domain/achievement.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementStatusProvider);

    return Scaffold(
      appBar: const LinuxDojoAppBar(
        title: 'Achievements',
        icon: Icons.emoji_events_outlined,
      ),
      body: SafeArea(
        child: achievements.when(
          data: (items) => _AchievementsBody(items: items),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _AchievementsError(
            onRetry: () => ref.invalidate(achievementStatusProvider),
          ),
        ),
      ),
    );
  }
}

class _AchievementsBody extends StatelessWidget {
  const _AchievementsBody({required this.items});

  final List<AchievementStatus> items;

  @override
  Widget build(BuildContext context) {
    final unlocked = items.where((item) => item.isUnlocked).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        _AchievementSummary(unlocked: unlocked, total: items.length),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _AchievementTile(status: items[index]),
        ),
      ],
    );
  }
}

class _AchievementSummary extends StatelessWidget {
  const _AchievementSummary({required this.unlocked, required this.total});

  final int unlocked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total == 0 ? 0.0 : unlocked / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
                  '$unlocked of $total unlocked',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.status});

  final AchievementStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = status.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: unlocked
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                unlocked
                    ? _achievementIcon(status.definition.category)
                    : Icons.lock_outline,
                size: 22,
                color: unlocked
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const Spacer(),
              if (unlocked)
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
          const Spacer(),
          Text(
            status.definition.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status.definition.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: unlocked
                  ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsError extends StatelessWidget {
  const _AchievementsError({required this.onRetry});

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
              'Could not load achievements',
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

IconData _achievementIcon(AchievementCategory category) {
  return switch (category) {
    AchievementCategory.sessions => Icons.event_available,
    AchievementCategory.cards => Icons.style_outlined,
    AchievementCategory.accuracy => Icons.gps_fixed,
    AchievementCategory.streak => Icons.local_fire_department,
    AchievementCategory.goals => Icons.flag_outlined,
    AchievementCategory.mastery => Icons.school_outlined,
    AchievementCategory.multipleChoice => Icons.checklist,
  };
}
