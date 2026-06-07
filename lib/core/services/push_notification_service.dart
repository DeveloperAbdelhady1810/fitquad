import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../rouets/app_router.dart';
import '../../features/member/home/ui/widgets/member_chat_screen.dart';
import 'api_client.dart';

/// Top-level handler for background / terminated messages.
/// Must be a top-level (non-class) function.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages are shown automatically by the OS.
  // Nothing extra needed here unless you want silent data processing.
}

class PushNotificationService {
  PushNotificationService._();

  static final _messaging = FirebaseMessaging.instance;

  static final _localPlugin = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'fitquad_default',
    'FitQuad Notifications',
    description: 'Messages, plans, streaks and announcements',
    importance: Importance.high,
    playSound: true,
  );

  // ── Initialise ──────────────────────────────────────────────────────────────

  static Future<void> init() async {
    // Register background handler (must be before FirebaseMessaging.onMessage)
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // Create the high-importance Android notification channel
    await _localPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Request permission (shows dialog on iOS, Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // iOS: must present alerts/badges/sounds when app is in foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Save token to the backend whenever it's issued / rotated
    // getToken() throws on iOS simulators (no APNs) — ignore that case
    try {
      final token = await _messaging.getToken();
      if (token != null) await _saveToken(token);
    } catch (_) {}
    _messaging.onTokenRefresh.listen(_saveToken);

    // Foreground messages → show a local notification so the user sees it
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // User tapped a notification while app was in background
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

    // App was launched from a terminated state via a notification tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _onNotificationTap(initial);

    // Init local notifications plugin (needed for foreground display)
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings();
    await _localPlugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  // ── Foreground message → show as local notification ─────────────────────────

  static void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  // ── Navigation on tap ────────────────────────────────────────────────────────

  static void _onNotificationTap(RemoteMessage message) {
    _navigate(message.data);
  }

  static void _onLocalNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigate(data);
    } catch (_) {}
  }

  static void _navigate(Map<String, dynamic> data) {
    final type = data['type'] as String? ?? '';
    final ctx  = AppRouter.navigatorKey.currentContext;
    if (ctx == null) return;

    switch (type) {
      case 'message':
      case 'plan':
        final coachName = data['coach_name'] as String? ?? 'Coach';
        final coachUrl  = data['coach_avatar'] as String?;
        Navigator.of(ctx).push(MaterialPageRoute(
          builder: (_) => MemberChatScreen(
            coachName: coachName,
            coachAvatarUrl: coachUrl,
          ),
        ));
        break;
      case 'announcement':
      case 'broadcast':
        GoRouter.of(ctx).go('/notifications');
        break;
      default:
        GoRouter.of(ctx).go('/notifications');
    }
  }

  // ── Save FCM token to backend ────────────────────────────────────────────────

  static Future<void> _saveToken(String token) async {
    try {
      await ApiClient.put('/auth/profile', {'fcm_token': token});
    } catch (_) {}
  }

  // ── Subscribe / unsubscribe from topics ─────────────────────────────────────

  /// Call after login to subscribe to the user's role topic.
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  /// Call on logout.
  static Future<void> unsubscribeAll() async {
    await _messaging.unsubscribeFromTopic('members');
    await _messaging.unsubscribeFromTopic('coaches');
    final token = await _messaging.getToken();
    if (token != null) await _messaging.deleteToken();
  }
}
