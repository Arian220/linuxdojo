import 'package:linuxdojo/features/settings/data/notification_permission_service.dart';

class FakeNotificationPermissionService
    implements NotificationPermissionService {
  FakeNotificationPermissionService({this.granted = true});

  final bool granted;
  int calls = 0;
  int settingsCalls = 0;

  @override
  Future<bool> requestPermission() async {
    calls++;
    return granted;
  }

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> openSettings() async {
    settingsCalls++;
    return true;
  }
}
