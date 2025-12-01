import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    final settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print("Notification permission denied");
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Please enable notifications for the best experience')),
      );
      return;
    }

    final fcmToken = await _firebaseMessaging.getToken().catchError((error) {
      print('Error getting FCM token: $error');
      return null;
    });
    if (fcmToken != null) {
      print("FCM Token: $fcmToken");
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        print("Notification clicked: ${response.payload}");
        final navigator = Navigator.of(navigatorKey.currentContext!);
        final payload = json.decode(response.payload ?? '{}');
        if (payload['screen'] != null) {
          navigator.pushNamed(payload['screen']);
        }
      },
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling background message: ${message.data}");
  }

  Future<void> setNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    if (enabled) {
      await initNotifications();
    } else {
      await _firebaseMessaging.deleteToken();
      await _localNotifications.cancelAll();
    }
  }

  Future<bool> getNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (message.notification != null) {
      await _showLocalNotification(message);
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    print("Notification tapped: ${message.data}");
    final navigator = Navigator.of(navigatorKey.currentContext!);
    if (message.data['screen'] == 'profile') {
      navigator.pushNamed('/profile');
    } else if (message.data['screen'] == 'home') {
      navigator.pushNamed('/home');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'General Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      notificationDetails,
      payload: json.encode(message.data),
    );
  }
}