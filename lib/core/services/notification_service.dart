import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:game_city_app/modules/community/views/community_view.dart';
import 'package:game_city_app/modules/community/views/friend_requests_view.dart';
import 'package:game_city_app/modules/community/controllers/friends_controller.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'dart:convert';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  // Track the current active chat room ID
  static String? activeRoomId;

  Future<NotificationService> init() async {
    try {
      // 1. Request permissions (especially for iOS and Android 13+)
      // On iOS Safari Web, this can throw if not triggered by a user gesture.

      // 2. Initialize local notifications for foreground display
      // if (!kIsWeb) {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
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
      // }

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('!!! Raw Foreground Message Received !!!');
          print('From: ${message.from}');
          print('Notification Title: ${message.notification?.title}');
          print('Notification Body: ${message.notification?.body}');
          print('Data Content: ${message.data}');
        }
        _foregroundHandler(message);
      });

      // 5. Handle app opening from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleNotificationClick(message.data);
      });

      // 6. Handle notification that launched the app from terminated state
      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage.data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Notification Service Init Error: $e');
      }
      // Do not rethrow, so runApp() can still execute (fixes iOS Safari white screen)
    }

    return this;
  }

  void _foregroundHandler(RemoteMessage message) {
    if (kDebugMode) {
      print('--- New Foreground Message ---');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      print('------------------------------');
    }

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
    if (kIsWeb) return; // Skip local notifications on web for now

    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    try {
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
    } catch (e) {
      if (kDebugMode) {
        print('Error showing local notification: $e');
      }
    }
  }

  void _handleNotificationClick(Map<String, dynamic> data) async {
    if (kDebugMode) {
      print('--- Notification Clicked ---');
      print('Data: $data');
      print('----------------------------');
    }

    final String? type = data['type'];
    final String? id = data['targetId'] ?? data['id'] ?? data['gameId'];

    if (type == 'chat_message') {
      Get.to(() => const CommunityView());
    } else if (type == 'news' && id != null) {
      Get.toNamed(AppRoutes.newsDetails, arguments: {'newsId': id});
    } else if (type == 'new_game' && id != null) {
      // Close loading

      Get.toNamed(AppRoutes.gameDetails, arguments: {'gameId': id});
    } else if (type == 'friend_request') {
      if (!Get.isRegistered<FriendsController>()) {
        Get.put(FriendsController());
      }
      Get.to(() => const FriendRequestsView());
    } else if (type == 'friend_accept') {
      if (!Get.isRegistered<FriendsController>()) {
        Get.put(FriendsController());
      }
      Get.to(() => const CommunityView());
    } else if (type == 'chat_message' || type == 'chat') {
      // For chat messages without a roomId, we might want to navigate to a general chat list or profile
      Get.toNamed(AppRoutes.chatRoom);
    } else {
      // Default fallback
      if (Get.currentRoute != AppRoutes.home) {
        Get.offAllNamed(AppRoutes.home);
      }
    }
  }

  Future<String?> getToken() async {
    // if (kIsWeb) {
    //   return await _fcm.getToken(
    //     vapidKey:
    //         'BNlg9My1BdEL-IQFg8adErfR_0vSrChM-6LTlWinIOs2tiP-N6BKgM5t6yDIsQohJbTy2d66rGcE1VXDGtXhaK4', // Required for Web. Replace with your actual VAPID key from Firebase Console.
    //   );
    // }
    return await _fcm.getToken();
  }
}
