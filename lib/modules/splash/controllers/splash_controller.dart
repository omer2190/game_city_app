import 'package:game_city_app/core/values/api_constants.dart';
import 'package:game_city_app/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SplashController extends GetxController {
  SplashController() {
    print('SplashController constructor called');
  }

  final box = GetStorage();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    super.onInit();
    print('SplashController onInit called');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      if (GetPlatform.isAndroid) {
        // Initialize Firebase Messaging
        await _initializeFirebaseMessaging();

        // Get FCM token and send to API
        await _sendFCMTokenToAPI();
      }

      // Navigate to appropriate screen after a short delay
      await Future.delayed(const Duration(seconds: 2));

      final token = box.read('token');
      print('Token in SplashController: $token');
      if (token != null) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      print('Error during app initialization: $e');
      // Still navigate to home even if error
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get token
    String? token = await messaging.getToken();
    print('FCM Token: $token');

    // Store token
    if (token != null) {
      box.write('fcm_token', token);
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show local notification
        _showLocalNotification(message);
      }
    });

    // Handle when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
      // Handle navigation or action
    });
  }

  Future<void> _sendFCMTokenToAPI() async {
    String? token = box.read('fcm_token');
    if (token == null) return;

    // Check if user is logged in
    String? userToken = box.read('token');

    // Send to API
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/update-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          if (userToken != null) 'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token sent successfully');
      } else {
        print('Failed to send FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending FCM token: $e');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
