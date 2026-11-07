import 'package:drift/native.dart';
import 'package:linuxdojo/core/database/app_database.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
