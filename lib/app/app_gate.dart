import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/features/onboarding/presentation/onboarding_screen.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/shell/presentation/app_shell.dart';

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    return settings.when(
      data: (settings) => settings.onboardingCompleted
          ? const AppShell()
          : const OnboardingScreen(),
      loading: () => const _AppLoadingScreen(),
      error: (error, stackTrace) =>
          _AppGateError(onRetry: () => ref.invalidate(appSettingsProvider)),
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppGateError extends StatelessWidget {
  const _AppGateError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load preferences',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: onRetry, child: const Text('Try again')),
            ],
          ),
        ),
      ),
    );
  }
}
