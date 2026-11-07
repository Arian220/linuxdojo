import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:linuxdojo/core/database/seed/seed_models.dart';

abstract interface class SeedSource {
  Future<List<DeckSeed>> load();
}

class AssetSeedSource implements SeedSource {
  const AssetSeedSource();

  static const deckAssetPaths = [
    'assets/decks/01_basics.json',
    'assets/decks/02_files.json',
    'assets/decks/03_permissions.json',
    'assets/decks/04_processes.json',
    'assets/decks/05_networking.json',
    'assets/decks/06_users_groups.json',
    'assets/decks/07_text_processing.json',
    'assets/decks/08_system_information.json',
  ];

  @override
  Future<List<DeckSeed>> load() async {
    final decks = <DeckSeed>[];
    for (final path in deckAssetPaths) {
      final raw = await rootBundle.loadString(path);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      decks.add(DeckSeed.fromJson(json));
    }
    return decks;
  }
}
