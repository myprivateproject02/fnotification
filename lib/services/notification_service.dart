import 'dart:convert';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      AppSettings.openNotificationSettings();
      print('User declined or has not accepted permission');
    }
  }

  void initLocalNotificationSettings(
      BuildContext context, RemoteMessage message) async {
    // Android-specific configuration
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var androidConfig = const AndroidInitializationSettings(
        'app_icon'); // Replace app_icon with your app icon name
    var iosInitialize = const DarwinInitializationSettings();

    // Initialize the plugin with both Android and iOS settings
    var initializationSettings =
        InitializationSettings(android: androidInitialize, iOS: iosInitialize);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {},
        onDidReceiveBackgroundNotificationResponse: (payload) {});
  }

  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print("message received title: ${message.notification?.title}");
        print("message received body: ${message.notification?.body}");
      }
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        const AndroidNotificationChannel(
      'high_importance_channel',
      'Notification',
      importance: Importance.max,
    );

    var androidDetails = AndroidNotificationDetails(
      androidNotificationChannel.id.toString(), //channel id
      androidNotificationChannel.name.toString(), //channel name
      channelDescription: 'The Notification Application',
      playSound: true,
      enableVibration: true,
      icon: "@mipmap/ic_launcher",
      importance: Importance.max,
      enableLights: true,
      priority: Priority.max,
    );

    var iOSDetails = DarwinNotificationDetails(
      presentSound: true,
      presentBadge: true,
      presentAlert: true,
    );

    NotificationDetails notificationDetails =
        NotificationDetails(iOS: iOSDetails, android: androidDetails);

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title ?? "",
        message.notification?.body ?? "",
        notificationDetails,
        payload: json.encode(message.data),
      );
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }
}
