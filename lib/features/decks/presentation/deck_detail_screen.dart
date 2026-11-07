import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/models/difficulty_tag.dart';
import 'package:linuxdojo/core/theme/app_colors.dart';
import 'package:linuxdojo/core/theme/app_typography.dart';
import 'package:linuxdojo/features/decks/data/deck_repository.dart';
import 'package:linuxdojo/features/decks/domain/deck_summary.dart';

class DeckDetailScreen extends ConsumerWidget {
  const DeckDetailScreen({required this.deckId, super.key});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(deckSummaryProvider(deckId));
    final cards = ref.watch(deckCardsProvider(deckId));
    final deckName = summary.value?.deck.name ?? 'Deck';

    return Scaffold(
      appBar: AppBar(title: Text(deckName)),
      body: SafeArea(
        child: cards.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _DeckDetailError(
            onRetry: () => ref.invalidate(deckCardsProvider(deckId)),
          ),
          data: (deckCards) =>
              _DeckDetailBody(summary: summary.value, cards: deckCards),
        ),
      ),
    );
  }
}

class _DeckDetailBody extends StatelessWidget {
  const _DeckDetailBody({required this.summary, required this.cards});

  final DeckSummary? summary;
  final List<CardEntry> cards;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Center(child: Text('No cards in this deck.'));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (summary != null) ...[
          _DeckHeader(summary: summary!),
          const SizedBox(height: 20),
        ],
        for (final card in cards)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CardTile(card: card),
          ),
      ],
    );
  }
}

class _DeckHeader extends StatelessWidget {
  const _DeckHeader({required this.summary});

  final DeckSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deck = summary.deck;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            deck.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${summary.masteredCards} of ${summary.totalCards} mastered',
                style: theme.textTheme.labelMedium?.copyWith(
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
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  final CardEntry card;

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  card.prompt,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _DifficultyBadge(tag: card.difficultyTag),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            card.answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (card.example.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Text(
                card.example,
                style: AppTypography.command.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.tag});

  final DifficultyTag tag;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (tag) {
      DifficultyTag.novice => ('Novice', AppColors.primary),
      DifficultyTag.user => ('User', AppColors.secondary),
      DifficultyTag.admin => ('Admin', AppColors.warning),
      DifficultyTag.root => ('Root', AppColors.error),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: color,
        ),
      ),
    );
  }
}

class _DeckDetailError extends StatelessWidget {
  const _DeckDetailError({required this.onRetry});

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
              'Could not load this deck',
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
