import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memorize_scripture/app_manager.dart';
import 'package:memorize_scripture/pages/settings/settings_page.dart';
import 'package:memorize_scripture/pages/settings/settings_page_manager.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/notification_service.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeNotificationService implements NotificationService {
  bool permissionGranted = true;
  bool isCleared = false;
  bool isScheduled = false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> init() async {}

  @override
  Future<bool> requestNotificationPermission() async => permissionGranted;

  @override
  Future<void> scheduleNotifications() async {
    isScheduled = true;
  }

  @override
  Future<void> clearNotifications() async {
    isCleared = true;
  }
}

void main() {
  late UserSettings userSettings;
  late AppManager appManager;
  late FakeNotificationService fakeNotificationService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    userSettings = UserSettings();
    await userSettings.init();

    fakeNotificationService = FakeNotificationService();

    if (getIt.isRegistered<UserSettings>()) {
      getIt.unregister<UserSettings>();
    }
    getIt.registerSingleton<UserSettings>(userSettings);

    if (getIt.isRegistered<NotificationService>()) {
      getIt.unregister<NotificationService>();
    }
    getIt.registerSingleton<NotificationService>(fakeNotificationService);

    if (getIt.isRegistered<AppManager>()) {
      getIt.unregister<AppManager>();
    }
    appManager = AppManager();
    getIt.registerSingleton<AppManager>(appManager);
  });

  tearDown(() {
    if (getIt.isRegistered<UserSettings>()) {
      getIt.unregister<UserSettings>();
    }
    if (getIt.isRegistered<NotificationService>()) {
      getIt.unregister<NotificationService>();
    }
    if (getIt.isRegistered<AppManager>()) {
      getIt.unregister<AppManager>();
    }
  });

  group('SettingsPageManager notifications', () {
    test('default notification state is off with 20:00 time', () {
      final manager = SettingsPageManager();
      expect(manager.isNotificationsOn, isFalse);
      expect(manager.notificationTimeHour, 20);
      expect(manager.notificationTimeMinute, 0);
      expect(manager.notificationTimeDisplay, '20:00');
    });

    test('turning notifications ON requests permission and schedules', () async {
      final manager = SettingsPageManager();
      await manager.setNotifications(true);

      expect(manager.isNotificationsOn, isTrue);
      expect(userSettings.isNotificationsOn, isTrue);
      expect(fakeNotificationService.isScheduled, isTrue);
    });

    test('turning notifications OFF cancels and clears', () async {
      final manager = SettingsPageManager();
      await userSettings.setNotifications(true);
      expect(manager.isNotificationsOn, isTrue);

      await manager.setNotifications(false);
      expect(manager.isNotificationsOn, isFalse);
      expect(userSettings.isNotificationsOn, isFalse);
      expect(fakeNotificationService.isCleared, isTrue);
    });

    test('permission denied turns notification setting off', () async {
      fakeNotificationService.permissionGranted = false;
      final manager = SettingsPageManager();

      await manager.setNotifications(true);
      expect(manager.isNotificationsOn, isFalse);
      expect(userSettings.isNotificationsOn, isFalse);
    });

    test('updating notification time updates display and reschedules if on', () async {
      final manager = SettingsPageManager();
      await manager.setNotifications(true);
      fakeNotificationService.isScheduled = false;

      await manager.setNotificationTime(hour: 8, minute: 15);
      expect(manager.notificationTimeHour, 8);
      expect(manager.notificationTimeMinute, 15);
      expect(manager.notificationTimeDisplay, '8:15');
      expect(fakeNotificationService.isScheduled, isTrue);
    });
  });

  group('SettingsPage widget tests', () {
    testWidgets('renders Notifications section with switch and time tile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Daily reminder'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);

      final switchFinder = find.widgetWithText(SwitchListTile, 'Daily reminder');
      expect(switchFinder, findsOneWidget);
      final switchWidget = tester.widget<SwitchListTile>(switchFinder);
      expect(switchWidget.value, isFalse);
    });

    testWidgets('toggling Daily reminder switch updates state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsPage(),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.widgetWithText(SwitchListTile, 'Daily reminder');
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(userSettings.isNotificationsOn, isTrue);
      expect(fakeNotificationService.isScheduled, isTrue);
    });
  });
}
