import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }

  // Schedule water reminders every 2 hours from 9am to 9pm
  static Future<void> scheduleWaterReminders() async {
    await cancelWaterReminders();
    final now = tz.TZDateTime.now(tz.local);

    int id = 100;
    for (int hour = 9; hour <= 21; hour += 2) {
      var scheduled = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, hour);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id++,
        '💧 Stay Hydrated!',
        "Don't forget to drink water — tap to log",
        scheduled,
        _notifDetails('water', 'Water Reminders',
            'Daily hydration reminders every 2 hours'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // Schedule sleep reminder at 10:30pm
  static Future<void> scheduleSleepReminder() async {
    await cancelSleepReminder();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22, 30);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      200,
      '😴 Time to rest',
      'Prioritize 7-8 hours of sleep for optimal recovery',
      scheduled,
      _notifDetails('sleep', 'Sleep Reminders', 'Nightly sleep reminder'),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelWaterReminders() async {
    for (int id = 100; id < 120; id++) {
      await _plugin.cancel(id);
    }
  }

  static Future<void> cancelSleepReminder() async {
    await _plugin.cancel(200);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static NotificationDetails _notifDetails(
      String channelId, String channelName, String channelDesc) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
