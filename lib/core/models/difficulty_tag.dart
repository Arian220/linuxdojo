import 'package:drift/drift.dart';

enum DifficultyTag {
  novice('novice'),
  user('user'),
  admin('admin'),
  root('root');

  const DifficultyTag(this.value);

  final String value;

  static DifficultyTag fromValue(String value) {
    return values.firstWhere(
      (tag) => tag.value == value,
      orElse: () =>
          throw ArgumentError.value(value, 'value', 'Unknown difficulty tag'),
    );
  }
}

class DifficultyTagConverter extends TypeConverter<DifficultyTag, String> {
  const DifficultyTagConverter();

  @override
  DifficultyTag fromSql(String fromDb) => DifficultyTag.fromValue(fromDb);

  @override
  String toSql(DifficultyTag value) => value.value;
}
