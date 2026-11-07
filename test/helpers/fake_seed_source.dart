import 'package:linuxdojo/core/database/seed/seed_models.dart';
import 'package:linuxdojo/core/database/seed/seed_source.dart';

class FakeSeedSource implements SeedSource {
  const FakeSeedSource(this.decks);

  final List<DeckSeed> decks;

  @override
  Future<List<DeckSeed>> load() async => decks;
}
