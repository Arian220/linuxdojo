import 'package:flutter/material.dart';
import 'package:linuxdojo/core/widgets/feature_placeholder.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: const FeaturePlaceholder(
        icon: Icons.insights_outlined,
        title: 'Stats',
        message: 'Weekly progress, streaks, and achievements will appear here.',
      ),
    );
  }
}
