import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:notification/screens/home_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationLogic {
  static final _notification = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future<NotificationDetails> _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'schedule_reminder_channel', // channel id
        'Schedule Reminder', // channel name
        channelDescription:
            'Don\'t forget to Drink Water', // channel description
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher', // Use app icon instead of time_workout
      ),
    );
  }

  static Future<void> init(BuildContext context, String uId) async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Initialize notification settings
      final AndroidInitializationSettings androidInitialize =
          AndroidInitializationSettings('@mipmap/ic_launcher'); // Use app icon

      final InitializationSettings settings =
          InitializationSettings(android: androidInitialize);

      // Initialize notifications
      await _notification.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
          onNotification.add(response.payload);
        },
      );
    } catch (e) {
      print('Notification initialization error: $e');
    }
  }

  static Future<void> showNotifications({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime dateTime,
  }) async {
    try {
      if (dateTime.isBefore(DateTime.now())) {
        dateTime = dateTime.add(Duration(days: 1));
      }

      await _notification.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        await _notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
    } catch (e) {
      print('Show notification error: $e');
    }
  }

  // Add method to cancel notifications
  static Future<void> cancelNotification(int id) async {
    await _notification.cancel(id);
  }

  // Add method to cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }
}

/*import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:notification/screens/home_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationLogic {
  static final _notification = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();

  static Future _notificationDetails() async {
    return NotificationDetails(
        android: AndroidNotificationDetails(
            "Schedule Reminder", "Don't forget to Drink Water",
            importance: Importance.max, priority: Priority.max));
  }

  static Future init(BuildContext context, String uId) async {
    tz.initializeTimeZones();
    final android = AndroidInitializationSettings("time_workout");
    final setting = InitializationSettings(android: android);
    await _notification.initialize(setting,
        onDidReceiveNotificationResponse: (payload) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));

      onNotification.add(payload as String);
    });
  }

  static Future showNotifications({
    int id = 0,
    String? title,
    String? body,
    String? payload,
    required DateTime dateTime,
  }) async {
    if (dateTime.isBefore(DateTime.now())) {
      dateTime = dateTime.add(Duration(days: 1));
    }
    _notification.zonedSchedule(id, title, body,
        tz.TZDateTime.from(dateTime, tz.local), await _notificationDetails(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle // or AndroidScheduleMode.exact
        );
  }
}
*/
