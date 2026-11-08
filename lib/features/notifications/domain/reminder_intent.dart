import 'package:flutter/foundation.dart';

abstract final class ReminderIntent {
  static final studyRequests = ValueNotifier<int>(0);

  static void openStudy() {
    studyRequests.value++;
  }
}
