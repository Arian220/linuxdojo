import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/theme/app_colors.dart';
import 'package:linuxdojo/core/theme/app_typography.dart';

class FlipCard extends StatelessWidget {
  const FlipCard({
    required this.card,
    required this.isRevealed,
    this.onTap,
    super.key,
  });

  final CardEntry card;
  final bool isRevealed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !isRevealed,
      label: isRevealed ? 'Answer revealed' : 'Flip card to reveal the answer',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isRevealed ? null : onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: isRevealed ? 1 : 0),
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubicEmphasized,
          builder: (context, value, _) {
            final angle = value * math.pi;
            final showAnswer = angle >= math.pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: showAnswer
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _CardSurface(child: _AnswerContent(card: card)),
                    )
                  : _CardSurface(child: _PromptContent(card: card)),
            );
          },
        ),
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: child,
    );
  }
}

class _PromptContent extends StatelessWidget {
  const _PromptContent({required this.card});

  final CardEntry card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PROMPT',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Text(
                card.prompt,
                textAlign: TextAlign.center,
                style: AppTypography.commandLarge.copyWith(
                  fontSize: 22,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.touch_app_outlined,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Tap to reveal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnswerContent extends StatelessWidget {
  const _AnswerContent({required this.card});

  final CardEntry card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ANSWER',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  card.answer,
                  style: theme.textTheme.titleLarge?.copyWith(
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'EXAMPLE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Text(
                    card.example,
                    style: AppTypography.command.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
