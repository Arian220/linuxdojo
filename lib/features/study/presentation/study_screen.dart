import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/core/theme/app_colors.dart';
import 'package:linuxdojo/core/widgets/linuxdojo_app_bar.dart';
import 'package:linuxdojo/features/study/domain/review_grade.dart';
import 'package:linuxdojo/features/study/presentation/session_summary_screen.dart';
import 'package:linuxdojo/features/study/presentation/study_session_provider.dart';
import 'package:linuxdojo/features/study/presentation/study_session_state.dart';
import 'package:linuxdojo/features/study/presentation/widgets/flip_card.dart';
import 'package:linuxdojo/features/study/presentation/widgets/multiple_choice_card.dart';

class StudyScreen extends ConsumerWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(studySessionProvider);

    ref.listen(studySessionProvider, (previous, next) {
      final summary = next.value?.summary;
      final wasComplete = previous?.value?.isComplete ?? false;
      if (summary == null || wasComplete || !context.mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => SessionSummaryScreen(summary: summary),
        ),
      );
    });

    return Scaffold(
      appBar: LinuxDojoAppBar(
        title: 'Study',
        icon: Icons.school_outlined,
        leading: IconButton(
          tooltip: 'Close session',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: session.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              _StudyError(onRetry: () => ref.invalidate(studySessionProvider)),
          data: (state) => _StudyBody(
            state: state,
            onReveal: () => ref.read(studySessionProvider.notifier).reveal(),
            onGrade: (grade) =>
                ref.read(studySessionProvider.notifier).grade(grade),
            onSelectOption: (option) =>
                ref.read(studySessionProvider.notifier).selectOption(option),
            onContinueMultipleChoice: () => ref
                .read(studySessionProvider.notifier)
                .continueAfterMultipleChoice(),
          ),
        ),
      ),
    );
  }
}

class _StudyBody extends StatelessWidget {
  const _StudyBody({
    required this.state,
    required this.onReveal,
    required this.onGrade,
    required this.onSelectOption,
    required this.onContinueMultipleChoice,
  });

  final StudySessionState state;
  final VoidCallback onReveal;
  final ValueChanged<ReviewGrade> onGrade;
  final ValueChanged<String> onSelectOption;
  final VoidCallback onContinueMultipleChoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!state.hasCards) {
      return const _EmptyStudyState();
    }

    if (state.isComplete) {
      return const Center(child: CircularProgressIndicator());
    }

    final card = state.currentCard;
    if (card == null) {
      return const _EmptyStudyState();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Card ${state.currentIndex + 1} of ${state.total}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                '${(state.progress * 100).round()}%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.progress,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: card.isMultipleChoice
                ? MultipleChoiceCard(
                    key: ValueKey(card.card.id),
                    studyCard: card,
                    selectedOption: state.selectedOption,
                    enabled: !state.isGrading,
                    onSelect: onSelectOption,
                  )
                : FlipCard(
                    key: ValueKey(card.card.id),
                    card: card.card,
                    isRevealed: state.isRevealed,
                    onTap: state.isGrading ? null : onReveal,
                  ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 56, child: _buildAction()),
        ],
      ),
    );
  }

  Widget _buildAction() {
    if (state.isMultipleChoice) {
      if (state.isAnswered) {
        return FilledButton(
          onPressed: state.isGrading ? null : onContinueMultipleChoice,
          child: const Text('Continue'),
        );
      }
      return const _SessionHint(text: 'Select the best option.');
    }

    if (state.isRevealed) {
      return _GradeButtons(enabled: !state.isGrading, onGrade: onGrade);
    }

    return const _SessionHint(text: 'Tap the card to reveal the answer.');
  }
}

class _SessionHint extends StatelessWidget {
  const _SessionHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _GradeButtons extends StatelessWidget {
  const _GradeButtons({required this.enabled, required this.onGrade});

  final bool enabled;
  final ValueChanged<ReviewGrade> onGrade;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GradeButton(
          label: 'Again',
          color: AppColors.error,
          foregroundColor: AppColors.onError,
          onPressed: enabled ? () => onGrade(ReviewGrade.again) : null,
        ),
        const SizedBox(width: 8),
        _GradeButton(
          label: 'Hard',
          color: AppColors.warning,
          foregroundColor: AppColors.background,
          onPressed: enabled ? () => onGrade(ReviewGrade.hard) : null,
        ),
        const SizedBox(width: 8),
        _GradeButton(
          label: 'Good',
          color: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          onPressed: enabled ? () => onGrade(ReviewGrade.good) : null,
        ),
        const SizedBox(width: 8),
        _GradeButton(
          label: 'Easy',
          color: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          onPressed: enabled ? () => onGrade(ReviewGrade.easy) : null,
        ),
      ],
    );
  }
}

class _GradeButton extends StatelessWidget {
  const _GradeButton({
    required this.label,
    required this.color,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color color;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _EmptyStudyState extends StatelessWidget {
  const _EmptyStudyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 44,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'No cards due',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are all caught up. Come back later for the next review.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyError extends StatelessWidget {
  const _StudyError({required this.onRetry});

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
            Icon(Icons.error_outline, size: 44, color: theme.colorScheme.error),
            const SizedBox(height: 20),
            Text(
              'Could not start the session',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Something went wrong while loading your due cards.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
