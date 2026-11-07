import 'package:flutter/material.dart';
import 'package:linuxdojo/core/widgets/feature_placeholder.dart';

class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decks')),
      body: const FeaturePlaceholder(
        icon: Icons.layers_outlined,
        title: 'Decks',
        message: 'Browse the Linux command decks and track your progress.',
      ),
    );
  }
}
