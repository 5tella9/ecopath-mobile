// lib/core/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _dailyMarketingId = 1001;

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(settings);

    // Android 13+ permission
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'ecopath_daily_channel',
        'EcoPath Daily Reminder',
        channelDescription:
            'Daily marketing reminders to re-engage users with EcoPath.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
  }

  /// 🔔 Schedule daily marketing reminder at [hour]:[minute] local time
  Future<void> scheduleDailyMarketingReminder({
    int hour = 10,
    int minute = 0,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time for today already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _dailyMarketingId,
      'EcoPath reminder 🌱',
      'Take a small action today — open EcoPath and help the planet!',
      scheduledDate,
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // 🔁 This makes it repeat every day at the same time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// ❌ Cancel the daily reminder
  Future<void> cancelDailyMarketingReminder() async {
    await _plugin.cancel(_dailyMarketingId);
  }
}
