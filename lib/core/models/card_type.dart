import 'package:drift/drift.dart';

enum CardType {
  flip('flip'),
  multipleChoice('multiple_choice');

  const CardType(this.value);

  final String value;

  static CardType fromValue(String value) {
    return values.firstWhere(
      (type) => type.value == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown card type'),
    );
  }
}

class CardTypeConverter extends TypeConverter<CardType, String> {
  const CardTypeConverter();

  @override
  CardType fromSql(String fromDb) => CardType.fromValue(fromDb);

  @override
  String toSql(CardType value) => value.value;
}
