import 'package:flutter/material.dart';
import 'package:linuxdojo/core/widgets/feature_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LinuxDojo')),
      body: const FeaturePlaceholder(
        icon: Icons.terminal,
        title: 'Ready to practice',
        message: 'Your due cards and daily goal will appear here.',
        command: r'$ linuxdojo --study',
      ),
    );
  }
}
