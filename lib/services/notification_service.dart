// services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'uj_isms_messages';
  static const _channelName = 'Messages & Alerts';

  Future<void> initialize() async {
    // ── 1. Request permission ──────────────────────────────────────────────
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ── 2. Set up flutter_local_notifications ──────────────────────────────
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotif.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Create high-importance Android channel
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.max,
            playSound: true,
          ),
        );

    // ── 3. Show notification when app is in FOREGROUND ─────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = message.notification;
      if (notif == null) return;

      _localNotif.show(
        id: notif.hashCode,
        title: notif.title,
        body: notif.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );

      debugPrint('Foreground notification shown: ${notif.title}');
    });

    // ── 4. Handle notification tap (app in background) ────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped: ${message.notification?.title}');
    });
  }

  /// Call this right after the user successfully logs in.
  /// Saves their device FCM token to Firestore under users/{uid}.fcmToken
  Future<void> saveTokenForUser(String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});

      debugPrint('FCM token saved for user $userId');

      // Refresh the token automatically if Firebase rotates it
      _messaging.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'fcmToken': newToken});
        debugPrint('FCM token refreshed for user $userId');
      });
    } catch (e) {
      debugPrint('Failed to save FCM token: $e');
    }
  }

  Future<String?> getToken() => _messaging.getToken();
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
      'Background notification received: ${message.notification?.title}');
}