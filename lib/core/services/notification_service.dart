import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:convert';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // Track the current active chat room ID
  static String? activeRoomId;

  Future<NotificationService> init() async {
    // 1. Request permissions (especially for iOS and Android 13+)
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 2. Initialize local notifications for foreground display
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final data = jsonDecode(details.payload!);
          _handleNotificationClick(data);
        }
      },
    );

    // 3. Create Android notification channel
    const channel = AndroidNotificationChannel(
      'chat_messages',
      'رسائل الدردشة',
      description: 'إشعارات الرسائل الجديدة في غرف الدردشة',
      importance: Importance.max,
      playSound: true,
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _foregroundHandler(message);
    });

    // 5. Handle app opening from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    return this;
  }

  void _foregroundHandler(RemoteMessage message) {
    // Extract data
    final String? roomId = message.data['roomId'];

    // RULE: If we are in the same room as the message, IGNORE it
    if (activeRoomId != null && activeRoomId == roomId) {
      return;
    }

    // Show a local notification (or snackbar) in the foreground
    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_messages',
          'رسائل الدردشة',
          channelDescription: 'إشعارات الرسائل الجديدة في غرف الدردشة',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    final String? roomId = data['roomId'];

    if (roomId != null) {
      // Navigate to chat room
      // Get.toNamed('/chat-room', arguments: {'roomId': roomId, 'roomName': roomName});
      // Adjust this based on your actual routing
    }
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
