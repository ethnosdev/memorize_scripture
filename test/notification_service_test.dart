import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  late UserSettings userSettings;

  setUpAll(() {
    tz.initializeTimeZones();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    userSettings = UserSettings();
    await userSettings.init();
    if (getIt.isRegistered<UserSettings>()) {
      getIt.unregister<UserSettings>();
    }
    getIt.registerSingleton<UserSettings>(userSettings);
  });

  tearDown(() {
    if (getIt.isRegistered<UserSettings>()) {
      getIt.unregister<UserSettings>();
    }
  });

  group('NotificationService nextInstanceOf calculation', () {
    test('returns time in the future if hour/minute has already passed today', () {
      final service = NotificationService(userSettings: userSettings);
      final now = tz.TZDateTime.now(tz.local);

      // Pick a time guaranteed to have passed today (or earlier minute if hour 0)
      final passedHour = (now.hour > 0) ? now.hour - 1 : 0;
      final passedMinute = (now.hour > 0) ? now.minute : ((now.minute > 0) ? now.minute - 1 : 0);

      // If it's literally midnight 00:00:00, nextInstanceOf(0, 0) should be tomorrow
      final result = service.nextInstanceOf(passedHour, passedMinute);

      expect(result.isAfter(now), isTrue,
          reason: 'Scheduled date must always be strictly in the future');
      expect(result.hour, passedHour);
      expect(result.minute, passedMinute);
    });

    test('returns today if hour/minute is in the future today', () {
      final service = NotificationService(userSettings: userSettings);
      final now = tz.TZDateTime.now(tz.local);

      // If current hour is 23, we can't test a future hour today, but we can test logic
      if (now.hour < 23) {
        final futureHour = now.hour + 1;
        final result = service.nextInstanceOf(futureHour, 0);

        expect(result.isAfter(now), isTrue);
        expect(result.year, now.year);
        expect(result.month, now.month);
        expect(result.day, now.day);
        expect(result.hour, futureHour);
        expect(result.minute, 0);
      }
    });

    test('never returns date in the past for any hour/minute 0..23', () {
      final service = NotificationService(userSettings: userSettings);
      final now = tz.TZDateTime.now(tz.local);

      for (int h = 0; h < 24; h++) {
        for (int m = 0; m < 60; m += 15) {
          final result = service.nextInstanceOf(h, m);
          expect(result.isAfter(now), isTrue,
              reason: 'nextInstanceOf($h, $m) should always be after now');
        }
      }
    });
  });

  group('UserSettings notifications', () {
    test('default notification settings', () {
      expect(userSettings.isNotificationsOn, isFalse);
      expect(userSettings.getNotificationTime, (20, 0));
    });

    test('updates notification toggle', () async {
      await userSettings.setNotifications(true);
      expect(userSettings.isNotificationsOn, isTrue);

      await userSettings.setNotifications(false);
      expect(userSettings.isNotificationsOn, isFalse);
    });

    test('updates notification time', () async {
      await userSettings.setNotificationTime(hour: 7, minute: 30);
      expect(userSettings.getNotificationTime, (7, 30));
    });
  });
}
