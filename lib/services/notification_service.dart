import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final UserSettings _userSettings;
  bool _isInitialized = false;

  NotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    UserSettings? userSettings,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _userSettings = userSettings ?? getIt<UserSettings>();

  FlutterLocalNotificationsPlugin get plugin => _plugin;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (kIsWeb) return;

    try {
      tz.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      } catch (e) {
        debugPrint('Could not set local timezone name: $e, falling back to UTC');
        try {
          tz.setLocalLocation(tz.getLocation('UTC'));
        } catch (_) {}
      }

      const androidSettings = AndroidInitializationSettings('notification_icon');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(settings: settings);
      _isInitialized = true;
    } catch (e, stack) {
      debugPrint('NotificationService init error: $e\n$stack');
    }
  }

  Future<bool> requestNotificationPermission() async {
    if (kIsWeb) return false;

    try {
      if (Platform.isIOS) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(
                  alert: true,
                  badge: true,
                  sound: true,
                ) ??
            false;
      } else if (Platform.isAndroid) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            false;
      } else if (Platform.isMacOS) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(
                  alert: true,
                  badge: true,
                  sound: true,
                ) ??
            false;
      }
    } catch (e, stack) {
      debugPrint('NotificationService requestPermission error: $e\n$stack');
    }
    return false;
  }

  Future<void> scheduleNotifications() async {
    if (kIsWeb) return;
    if (!_userSettings.isNotificationsOn) return;

    try {
      if (!_isInitialized) {
        await init();
      }

      await _plugin.cancelAll();

      const android = AndroidNotificationDetails(
        'memorize_scripture_notifications',
        'Memorize Scripture Daily Reminders',
        channelDescription:
            'Receive daily reminders to review and memorize your verses.',
      );

      const darwin = DarwinNotificationDetails();

      const specifics = NotificationDetails(
        android: android,
        iOS: darwin,
        macOS: darwin,
      );

      final (hour, minute) = _userSettings.getNotificationTime;
      final scheduledDate = nextInstanceOf(hour, minute);

      await _plugin.zonedSchedule(
        id: 0,
        title: 'Daily reminder',
        body: "Don't forget to review your old verses or learn a new one today.",
        scheduledDate: scheduledDate,
        notificationDetails: specifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, stack) {
      debugPrint('NotificationService scheduleNotifications error: $e\n$stack');
    }
  }

  Future<void> clearNotifications() async {
    if (kIsWeb) return;

    try {
      await _plugin.cancelAll();
    } catch (e, stack) {
      debugPrint('NotificationService clearNotifications error: $e\n$stack');
    }
  }

  tz.TZDateTime nextInstanceOf(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
