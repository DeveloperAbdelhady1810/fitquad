import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/push_notification_service.dart';

class AuthRepository {
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/login',
      {'email': email, 'password': password},
      auth: false,
    );
    final data = response['data'] as Map<String, dynamic>;
    await ApiClient.saveToken(data['token'] as String);
    final role = data['user']?['role'] as String? ?? 'member';
    await ApiClient.saveRole(role);
    await PushNotificationService.subscribeToTopic(role == 'member' ? 'members' : 'coaches');
    await _registerFcmToken();
    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final response = await ApiClient.post(
      '/auth/register',
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'role': role,
        if (phone != null) 'phone': phone,
      },
      auth: false,
    );
    final data = response['data'] as Map<String, dynamic>;
    await ApiClient.saveToken(data['token'] as String);
    final savedRole = data['user']?['role'] as String? ?? role;
    await ApiClient.saveRole(savedRole);
    await PushNotificationService.subscribeToTopic(savedRole == 'member' ? 'members' : 'coaches');
    await _registerFcmToken();
    return data;
  }

  static Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String providerId,
    String? email,
    String? name,
  }) async {
    final response = await ApiClient.post(
      '/auth/social',
      {
        'provider': provider,
        'provider_id': providerId,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      },
      auth: false,
    );
    final data = response['data'] as Map<String, dynamic>;
    await ApiClient.saveToken(data['token'] as String);
    await ApiClient.saveRole(data['user']?['role'] as String? ?? 'member');
    await PushNotificationService.subscribeToTopic('members');
    await _registerFcmToken();
    return data;
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout', {});
    } finally {
      await ApiClient.clearToken();
      await PushNotificationService.unsubscribeAll();
    }
  }

  static Future<Map<String, dynamic>> me() async {
    final response = await ApiClient.get('/auth/me');
    return response['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await ApiClient.put('/auth/profile', data);
    return response['data'] as Map<String, dynamic>;
  }

  static Future<void> _registerFcmToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await ApiClient.put('/auth/profile', {'fcm_token': token});
      }
    } catch (_) {}
  }
}
