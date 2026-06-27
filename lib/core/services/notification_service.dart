import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:game_city_app/modules/community/views/community_view.dart';
import 'package:game_city_app/modules/community/views/friend_requests_view.dart';
import 'package:game_city_app/modules/community/controllers/friends_controller.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends GetxService {
  static NotificationService get to => Get.find();

  final _fcm = FirebaseMessaging.instance;
  final _local = FlutterLocalNotificationsPlugin();

  static String? activeRoomId;

  Future<NotificationService> init() async {
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _local.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          if (details.payload != null) {
            final data = jsonDecode(details.payload!);
            _handleNotificationClick(data);
          }
        },
      );

      const channel = AndroidNotificationChannel(
        'chat_messages',
        'رسائل الدردشة',
        description: 'إشعارات الرسائل الجديدة في غرف الدردشة',
        importance: Importance.max,
        playSound: true,
      );

      await _local
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      FirebaseMessaging.onMessage.listen(_foregroundHandler);

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleNotificationClick(message.data);
      });

      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage.data);
      }
    } catch (e) {
      if (kDebugMode) print('NotificationService init error: $e');
    }

    return this;
  }

  void _foregroundHandler(RemoteMessage message) {
    if (kDebugMode) {
      print('Foreground message: ${message.notification?.title} | ${message.data}');
    }

    final roomId = message.data['targetId'];
    if (activeRoomId != null && activeRoomId == roomId) return;

    _showLocalNotification(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;
    if (notification == null) return;

    try {
      await _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
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
      if (kDebugMode) print('Local notification error: $e');
    }
  }

  void _handleNotificationClick(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('Notification clicked: $data');
    }

    final type = data['type'] as String?;
    final targetId = data['targetId'] as String?;

    switch (type) {
      case 'news':
      case 'comment':
      case 'new_like':
        if (targetId != null) {
          Get.toNamed(AppRoutes.newsDetails, arguments: {'newsId': targetId});
        } else {
          Get.toNamed(AppRoutes.news);
        }
        break;

      case 'new_game':
      case 'wishlist_free':
      case 'wishlist_discount':
      case 'wishlist_released':
        if (targetId != null) {
          Get.toNamed(AppRoutes.gameDetails, arguments: {'gameId': targetId});
        } else {
          Get.toNamed(AppRoutes.game);
        }
        break;

      case 'looking_for_players':
        if (targetId != null) {
          Get.toNamed(AppRoutes.gameDetails, arguments: {'gameId': targetId});
        } else {
          Get.toNamed(AppRoutes.onlineSearch);
        }
        break;

      case 'friend_request':
        if (!Get.isRegistered<FriendsController>()) {
          Get.put(FriendsController());
        }
        Get.to(() => const FriendRequestsView());
        break;

      case 'friend_accept':
        Get.toNamed(AppRoutes.chatRoom);
        break;

      case 'chat_message':
      case 'chat':
        Get.toNamed(AppRoutes.chatRoom);
        break;

      case 're_engagement':
      case 'broadcast':
      default:
        if (Get.currentRoute != AppRoutes.home) {
          Get.offAllNamed(AppRoutes.home);
        }
        break;
    }
  }

  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
