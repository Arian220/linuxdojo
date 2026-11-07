import 'package:flutter/material.dart';
import 'package:linuxdojo/core/widgets/feature_placeholder.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const FeaturePlaceholder(
        icon: Icons.settings_outlined,
        title: 'Settings',
        message: 'Study preferences, reminders, and app info will appear here.',
      ),
    );
  }
}
