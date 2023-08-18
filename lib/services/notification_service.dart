import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:memorize_scripture/service_locator.dart';
import 'package:memorize_scripture/services/user_settings.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final plugin = FlutterLocalNotificationsPlugin();
  final userSettings = getIt<UserSettings>();

  Future<void> init() async {
    if (Platform.isMacOS) {
      return;
    }
    tz.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const androidSettings = AndroidInitializationSettings('notification_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await plugin.initialize(settings);

    // check if the user has notifications turned on
    // if so, cancel all pending notifications
    // then schedule notifications for the next 4 days
    // the ID for each day is the date yyyymmdd
  }

  Future<void> scheduleNotifications({int days = 4}) async {
    if (!userSettings.isNotificationsOn) return;
    await plugin.cancelAll();

    const android = AndroidNotificationDetails(
      'memorize_scripture_notifications',
      'Memorize Scripture Daily Reminders',
      channelDescription: 'Receive daily reminders to review and memorize '
          'your verses.',
    );

    const ios = DarwinNotificationDetails();

    const specifics = NotificationDetails(
      android: android,
      iOS: ios,
    );

    final (hour, minute) = userSettings.getNotificationTime;
    const type = UILocalNotificationDateInterpretation.wallClockTime;

    print('scheduling notifications');

    for (int i = 1; i <= days; i++) {
      final date = DateTime.now().add(Duration(days: i));

      final scheduledTime = tz.TZDateTime.from(
        DateTime(date.year, date.month, date.day, hour, minute, 0),
        tz.local,
      );
      final id = date.day;
      await plugin.zonedSchedule(
        id,
        'Memorize Scripture',
        'Remember to review your old verses or learn a new one today.',
        scheduledTime,
        specifics,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: type,
      );
    }
  }

  Future<void> clearNotifications() async {
    print('clearing notifications');
    await plugin.cancelAll();
  }
}
