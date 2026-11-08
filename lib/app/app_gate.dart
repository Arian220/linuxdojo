import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/app/app_startup_provider.dart';
import 'package:linuxdojo/core/database/database_provider.dart';
import 'package:linuxdojo/core/widgets/linuxdojo_logo.dart';
import 'package:linuxdojo/features/notifications/domain/reminder_intent.dart';
import 'package:linuxdojo/features/onboarding/presentation/onboarding_screen.dart';
import 'package:linuxdojo/features/settings/data/settings_repository.dart';
import 'package:linuxdojo/features/shell/presentation/app_shell.dart';
import 'package:linuxdojo/features/study/presentation/study_screen.dart';

class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key});

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> {
  bool _canOpenStudy = false;
  int _lastHandledStudyRequest = 0;

  @override
  void initState() {
    super.initState();
    _lastHandledStudyRequest = ReminderIntent.studyRequests.value;
    ReminderIntent.studyRequests.addListener(_handleStudyRequest);
  }

  @override
  void dispose() {
    ReminderIntent.studyRequests.removeListener(_handleStudyRequest);
    super.dispose();
  }

  void _handleStudyRequest() {
    final requestCount = ReminderIntent.studyRequests.value;
    if (!_canOpenStudy || requestCount <= _lastHandledStudyRequest) return;

    _lastHandledStudyRequest = requestCount;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const StudyScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final startup = ref.watch(appStartupProvider);

    return startup.when(
      data: (_) => ref
          .watch(appSettingsProvider)
          .when(
            data: (settings) {
              if (!settings.onboardingCompleted) {
                _canOpenStudy = false;
                return const OnboardingScreen();
              }
              _canOpenStudy = true;
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _handleStudyRequest(),
              );
              return const AppShell();
            },
            loading: () => const _AppLoadingScreen(),
            error: (error, stackTrace) => _AppGateError(
              message: 'Could not load preferences',
              onRetry: () => ref.invalidate(appSettingsProvider),
            ),
          ),
      loading: () => const _AppLoadingScreen(),
      error: (error, stackTrace) => _AppGateError(
        message: 'Could not prepare app data',
        onRetry: () {
          ref.invalidate(databaseSeedProvider);
          ref.invalidate(appStartupProvider);
        },
      ),
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LinuxDojoLogo(size: 95),
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
  const _AppGateError({required this.message, required this.onRetry});

  final String message;
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
                message,
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
