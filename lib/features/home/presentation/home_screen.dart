import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/theme/app_typography.dart';
import 'package:linuxdojo/features/study/presentation/study_screen.dart';
import 'package:linuxdojo/features/study/presentation/study_session_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dueCards = ref.watch(dueCardsProvider);
    final hasDueCards = dueCards.value?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('LinuxDojo')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.terminal,
                          size: 56,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Ready to practice?',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Review your due Linux command cards.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        dueCards.when(
                          data: (cards) =>
                              _DueCardsSummary(count: cards.length),
                          loading: () => const SizedBox(
                            height: 96,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stackTrace) => _DueCardsError(
                            onRetry: () => ref.invalidate(dueCardsProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: hasDueCards
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const StudyScreen(),
                        ),
                      )
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Study'),
              ),
              const SizedBox(height: 12),
              Text(
                r'$ linuxdojo --study',
                textAlign: TextAlign.center,
                style: AppTypography.command.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueCardsSummary extends StatelessWidget {
  const _DueCardsSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (count == 0) {
      return Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 36,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'All caught up',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No cards are due right now.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          '$count',
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count == 1 ? 'card due' : 'cards due',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DueCardsError extends StatelessWidget {
  const _DueCardsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(Icons.error_outline, size: 36, color: theme.colorScheme.error),
        const SizedBox(height: 12),
        Text(
          'Could not load due cards',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}
