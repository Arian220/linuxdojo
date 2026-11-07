import 'package:linuxdojo/core/database/app_database.dart';
import 'package:linuxdojo/core/models/card_type.dart';

class StudyCard {
  const StudyCard({required this.card, this.options = const []});

  final CardEntry card;
  final List<String> options;

  bool get isMultipleChoice => card.type == CardType.multipleChoice;
}
