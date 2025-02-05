import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:notification/screens/home_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationLogic {
  static final FlutterLocalNotificationsPlugin _notification = FlutterLocalNotificationsPlugin();
  static final onNotification = BehaviorSubject<String?>();
  static bool _initialized = false;

  // Channel IDs
  static const String _channelId = 'schedule_reminder_channel';
  static const String _channelName = 'Schedule Reminder';
  static const String _channelDescription = 'Reminder notifications channel';

  /// Initialize notification settings and permissions
  static Future<void> init(BuildContext context, String uId) async {
    if (_initialized) return;

    try {
      // Initialize timezone
      await _initializeTimeZone();

      // Request permissions
      await requestNotificationPermissions();

      // Initialize notification settings
      await _initializeNotificationSettings(context);

      _initialized = true;
      print('Notification system initialized successfully');

      await printPendingNotifications();

    } catch (e, stackTrace) {
      print('Notification initialization error: $e');
      print('Stack trace: $stackTrace');
      // Continue with default settings if initialization fails
      _initialized = true;
    }
  }

  /// Initialize timezone settings
  static Future<void> _initializeTimeZone() async {
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('Timezone initialized: $timeZoneName');
    } catch (e) {
      print('Timezone initialization error: $e');
      // Fallback to UTC if there's an error
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Request notification permissions
  static Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      try {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notification.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

        // For Android 13 and above
        final bool? permissionGranted =
        await androidImplementation?.requestNotificationsPermission();
        print('Notification permission granted: $permissionGranted');

        // Request precise alarms permission for Android 12 and above
        final bool? exactAlarmsGranted =
        await androidImplementation?.requestExactAlarmsPermission();
        print('Exact alarms permission granted: $exactAlarmsGranted');

        // Check if notifications are enabled
        final bool? areNotificationsEnabled =
        await androidImplementation?.areNotificationsEnabled();
        print('Notifications enabled: $areNotificationsEnabled');

      } catch (e) {
        print('Error requesting permissions: $e');
      }
    }
  }

  /// Initialize notification settings
  static Future<void> _initializeNotificationSettings(BuildContext context) async {
    try {
      const AndroidInitializationSettings androidInitialize =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings =
      InitializationSettings(android: androidInitialize);

      await _notification.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationResponse(response, context);
        },
      );
    } catch (e) {
      print('Error initializing notification settings: $e');
    }
  }
  /// Handle notification response
  static void _handleNotificationResponse(
      NotificationResponse response, BuildContext context) {
    print('Notification response received with payload: ${response.payload}');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
    onNotification.add(response.payload);
  }

  /// Configure notification details
  static Future<NotificationDetails> _notificationDetails() async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
        enableLights: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        actions: [
          AndroidNotificationAction('dismiss', 'Dismiss'),
          AndroidNotificationAction('snooze', 'Snooze'),
        ],
      ),
    );
  }

  /// Schedule a notification
  static Future<void> showNotifications({
    required int id,
    required String title,
    required String body,
    String? payload,
    required DateTime dateTime,
  }) async {
    try {
      // Ensure the dateTime is in the future
      DateTime scheduleTime = dateTime;
      if (dateTime.isBefore(DateTime.now())) {
        scheduleTime = dateTime.add(const Duration(days: 1));
      }

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduleTime, tz.local);
      print('Scheduling notification ID:$id for: $scheduledDate');

      await _notification.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        await _notificationDetails(),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );

      print('Notification ID:$id scheduled successfully');
      await printPendingNotifications();

    } catch (e, stackTrace) {
      print('Show notification error for ID:$id: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int id) async {
    try {
      await _notification.cancel(id);
      print('Notification ID:$id cancelled');
      await printPendingNotifications();
    } catch (e) {
      print('Error cancelling notification ID:$id: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await _notification.cancelAll();
      print('All notifications cancelled');
      await printPendingNotifications();
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  /// Print pending notifications for debugging
  static Future<void> printPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
      await _notification.pendingNotificationRequests();
      print('Pending notifications count: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        print('ID: ${notification.id}, Title: ${notification.title}');
      }
    } catch (e) {
      print('Error getting pending notifications: $e');
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notification.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final bool? enabled = await androidImplementation?.areNotificationsEnabled();
      return enabled ?? false;
    }
    return false;
  }
}
class FCMService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const Duration _tokenTimeout = Duration(seconds: 10);
  static const int _maxRetryAttempts = 3;

  static Future<void> init() async {
    try {
      // Request permission with timeout
      await _requestPermissionWithTimeout();

      // Configure local notifications
      await _initLocalNotifications();

      // Get FCM token with retry mechanism
      String? token = await _getTokenWithRetry();
      if (token != null) {
        print('FCM Token: $token');
        await _updateTokenInFirestore(token);
      }

      // Configure message handlers
      await _configureMessageHandlers();

    } catch (e) {
      print('FCM initialization error: $e');
      // Continue with local notifications only
    }
  }

  static Future<void> _requestPermissionWithTimeout() async {
    try {
      final result = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,
      ).timeout(_tokenTimeout);

      print('Authorization status: ${result.authorizationStatus}');
    } catch (e) {
      print('Failed to request FCM permission: $e');
      rethrow;
    }
  }

  static Future<void> _initLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings =
      InitializationSettings(android: androidSettings);

      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _handleLocalNotificationResponse,
      );
    } catch (e) {
      print('Failed to initialize local notifications: $e');
      rethrow;
    }
  }

  static Future<String?> _getTokenWithRetry() async {
    for (int i = 0; i < _maxRetryAttempts; i++) {
      try {
        return await _firebaseMessaging
            .getToken()
            .timeout(_tokenTimeout);
      } catch (e) {
        print('Failed to get FCM token, attempt ${i + 1}: $e');
        if (i < _maxRetryAttempts - 1) {
          await Future.delayed(Duration(seconds: 2 * (i + 1))); // Exponential backoff
        }
      }
    }
    return null;
  }

  static Future<void> _updateTokenInFirestore(String token) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        print('Token updated in Firestore successfully');
      }
    } catch (e) {
      print('Failed to update token in Firestore: $e');
    }
  }

  static Future<void> _configureMessageHandlers() async {
    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM token refreshed: $newToken');
      _updateTokenInFirestore(newToken);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check for initial message
    RemoteMessage? initialMessage =
    await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  static void _handleLocalNotificationResponse(NotificationResponse response) {
    print('Local notification response: ${response.payload}');
    // Handle the notification response
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.data}');

    try {
      AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      NotificationDetails details = NotificationDetails(android: androidDetails);

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'New Message',
        message.notification?.body,
        details,
        payload: json.encode(message.data),
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  static void _handleNotificationOpen(RemoteMessage message) {
    print('Notification opened: ${message.data}');
    // Navigate to appropriate screen based on message data
    // Implement your navigation logic here
  }

  // Method to manually refresh FCM token
  static Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      final String? newToken = await _getTokenWithRetry();
      if (newToken != null) {
        await _updateTokenInFirestore(newToken);
      }
      return newToken;
    } catch (e) {
      print('Error refreshing FCM token: $e');
      return null;
    }
  }
}

// Background message handler must be a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    print('Handling background message: ${message.data}');
    // Implement your background message handling logic here
  } catch (e) {
    print('Error handling background message: $e');
  }
}