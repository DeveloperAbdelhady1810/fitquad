import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../rouets/app_router.dart';
import 'api_client.dart';

// ─── Background handler (must be top-level) ──────────────────────────────────

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  // No navigation here — the app may not be running.
}

// ─── Service ──────────────────────────────────────────────────────────────────

class NotificationService {
  static final _fln = FlutterLocalNotificationsPlugin();
  static const _channelId   = 'high_importance_channel';
  static const _channelName = 'FitQuad Notifications';

  /// Call once in main() before runApp(), after Firebase.initializeApp().
  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    if (Platform.isAndroid) {
      await _fln
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
            _channelId,
            _channelName,
            importance: Importance.high,
          ));
    }

    await _fln.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == null) return;
        try {
          final data = jsonDecode(response.payload!) as Map<String, dynamic>;
          _handleTap(data);
        } catch (_) {}
      },
    );

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      FirebaseMessaging.onMessage.listen(_showLocal);
    }

    FirebaseMessaging.onMessageOpenedApp
        .listen((msg) => _handleTap(msg.data));
  }

  /// Call after the first frame to handle cold-start notification taps.
  static Future<void> checkInitialMessage() async {
    final msg = await FirebaseMessaging.instance.getInitialMessage();
    if (msg != null) _handleTap(msg.data);
  }

  /// Call after login to register the device token with the backend.
  static Future<void> syncToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiClient.put('/auth/fcm-token', {'fcm_token': token});
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
        try {
          await ApiClient.put('/auth/fcm-token', {'fcm_token': t});
        } catch (_) {}
      });
    } catch (_) {}
  }

  // ─── Internal ────────────────────────────────────────────────────────────────

  static void _handleTap(Map<String, dynamic> data) {
    final action   = data['action']    as String?;
    final actionId = data['action_id'] as String?;
    final _ = actionId != null ? int.tryParse(actionId) : null;
    final router   = AppRouter.getRouter();

    switch (action) {
      case 'message':
      case 'plan':
        router.go('/notifications');
      case 'announcement':
      case 'broadcast':
        router.go('/notifications');
      // Add more action cases here as needed:
      // case 'guest_pass':
      //   router.go('/guest-passes');
      default:
        router.go('/notifications');
    }
  }

  static void _showLocal(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    _fln.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }
}
