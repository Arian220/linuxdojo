import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linuxdojo/features/decks/presentation/decks_screen.dart';
import 'package:linuxdojo/features/home/presentation/home_screen.dart';
import 'package:linuxdojo/features/notifications/data/reminder_service.dart';
import 'package:linuxdojo/features/settings/data/notification_permission_service.dart';
import 'package:linuxdojo/features/settings/presentation/settings_screen.dart';
import 'package:linuxdojo/features/stats/presentation/stats_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  static const _screens = [
    HomeScreen(),
    DecksScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  int _selectedIndex = 0;
  String? _shownReminderError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationPermissionProvider);
      unawaited(_syncReminders());
    }
  }

  Future<void> _syncReminders() async {
    try {
      await ref.read(reminderServiceProvider).sync();
    } catch (error, stackTrace) {
      debugPrint('Could not refresh reminders: $error\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderError = ref.watch(reminderSyncStatusProvider);
    if (reminderError != null && reminderError != _shownReminderError) {
      _shownReminderError = reminderError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reminderError),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                setState(() => _selectedIndex = 3);
              },
            ),
          ),
        );
      });
    } else if (reminderError == null) {
      _shownReminderError = null;
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers),
            label: 'Decks',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
