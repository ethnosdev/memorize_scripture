import 'package:memorize_scripture/services/user_settings.dart';

class MockUserSettings implements UserSettings {
  @override
  Future<int?> getBuildNumber() async => 1;

  @override
  Future<bool> getDarkMode() async => true;

  @override
  Future<int?> getNewVerseFrequency() async => 1;

  @override
  Future<void> setBuildNumber(int buildNumber) async {}

  @override
  Future<void> setDarkMode(bool value) async {}

  @override
  Future<void> setNewVerseFrequency(int frequency) async {}
}
