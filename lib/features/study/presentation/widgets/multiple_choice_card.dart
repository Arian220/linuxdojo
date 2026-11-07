import 'package:flutter/material.dart';
import 'package:linuxdojo/core/theme/app_colors.dart';
import 'package:linuxdojo/core/theme/app_typography.dart';
import 'package:linuxdojo/features/study/domain/study_card.dart';

class MultipleChoiceCard extends StatelessWidget {
  const MultipleChoiceCard({
    required this.studyCard,
    required this.selectedOption,
    required this.enabled,
    required this.onSelect,
    super.key,
  });

  final StudyCard studyCard;
  final String? selectedOption;
  final bool enabled;
  final ValueChanged<String> onSelect;

  bool get _answered => selectedOption != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = studyCard.card;

    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: SingleChildScrollView(
        child: Column(
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
            const SizedBox(height: 20),
            Text(
              card.prompt,
              textAlign: TextAlign.center,
              style: AppTypography.commandLarge.copyWith(
                fontSize: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            for (final option in studyCard.options) ...[
              _OptionButton(
                key: ValueKey('option-$option'),
                label: option,
                state: _stateFor(option),
                onPressed: !_answered && enabled
                    ? () => onSelect(option)
                    : null,
              ),
              const SizedBox(height: 10),
            ],
            if (_answered)
              _Feedback(
                isCorrect: selectedOption == card.answer,
                answer: card.answer,
                example: card.example,
              ),
          ],
        ),
      ),
    );
  }

  _OptionState _stateFor(String option) {
    if (!_answered) return _OptionState.idle;

    if (option == studyCard.card.answer) return _OptionState.correct;
    if (option == selectedOption) return _OptionState.incorrect;
    return _OptionState.muted;
  }
}

enum _OptionState { idle, correct, incorrect, muted }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.state,
    required this.onPressed,
    super.key,
  });

  final String label;
  final _OptionState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (background, foreground, border) = switch (state) {
      _OptionState.correct => (
        AppColors.success.withValues(alpha: 0.16),
        AppColors.success,
        AppColors.success,
      ),
      _OptionState.incorrect => (
        AppColors.error.withValues(alpha: 0.16),
        AppColors.error,
        AppColors.error,
      ),
      _OptionState.muted => (
        theme.colorScheme.surface,
        theme.colorScheme.onSurfaceVariant,
        theme.colorScheme.outlineVariant,
      ),
      _OptionState.idle => (
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurface,
        theme.colorScheme.outline,
      ),
    };

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        alignment: Alignment.centerLeft,
        backgroundColor: background,
        foregroundColor: foreground,
        disabledBackgroundColor: background,
        disabledForegroundColor: foreground,
        side: BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: AppTypography.command.copyWith(
          color: foreground,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({
    required this.isCorrect,
    required this.answer,
    required this.example,
  });

  final bool isCorrect;
  final String answer;
  final String example;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = isCorrect ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 20,
                color: accent,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct' : 'Not quite',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Answer: $answer',
            style: AppTypography.command.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'EXAMPLE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            example,
            style: AppTypography.command.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
