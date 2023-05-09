import 'package:memorize_scripture/services/user_settings.dart';

class MockUserSettings implements UserSettings {
  @override
  Future<bool> getDarkMode() async => true;

  @override
  Future<void> setDarkMode(bool value) async {}

  @override
  Future<int> getDailyLimit() async => 1;

  @override
  Future<void> setDailyLimit(int value) async {}
}
