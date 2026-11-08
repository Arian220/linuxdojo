import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/widgets/feature_placeholder.dart';
import 'package:linuxdojo/core/widgets/linuxdojo_app_bar.dart';
import 'package:linuxdojo/features/decks/data/deck_repository.dart';
import 'package:linuxdojo/features/decks/domain/deck_summary.dart';
import 'package:linuxdojo/features/decks/presentation/deck_detail_screen.dart';

class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(deckSummariesProvider);

    return Scaffold(
      appBar: const LinuxDojoAppBar(
        title: 'Decks',
        icon: Icons.layers_outlined,
      ),
      body: SafeArea(
        child: decks.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _DecksError(onRetry: () => ref.invalidate(deckSummariesProvider)),
          data: (summaries) {
            if (summaries.isEmpty) {
              return const FeaturePlaceholder(
                icon: Icons.layers_outlined,
                title: 'No decks yet',
                message: 'Deck content will appear here once it is installed.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: summaries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final summary = summaries[index];
                return _DeckTile(
                  summary: summary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => DeckDetailScreen(deckId: summary.deck.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({required this.summary, required this.onTap});

  final DeckSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deck = summary.deck;
    final cardLabel = summary.totalCards == 1 ? 'card' : 'cards';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _deckIcon(deck.icon),
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deck.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          deck.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${summary.totalCards} $cardLabel',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${summary.masteredCards} / ${summary.totalCards} mastered',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: summary.progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecksError extends StatelessWidget {
  const _DecksError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Could not load decks',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

IconData _deckIcon(String icon) {
  return switch (icon) {
    'terminal' => Icons.terminal,
    'folder' => Icons.folder_outlined,
    'lock' => Icons.lock_outline,
    'memory' => Icons.memory,
    'lan' => Icons.lan_outlined,
    'group' => Icons.group_outlined,
    'text_fields' => Icons.text_fields,
    'info' => Icons.info_outline,
    _ => Icons.layers_outlined,
  };
}
