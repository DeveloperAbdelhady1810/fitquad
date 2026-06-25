import '../../../core/services/api_client.dart';
import '../../../core/services/notification_service.dart';

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
    await NotificationService.syncToken();
    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
    String? inviteCode,
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
        if (inviteCode != null && inviteCode.isNotEmpty)
          'invite_code': inviteCode.trim().toUpperCase(),
      },
      auth: false,
    );
    final data = response['data'] as Map<String, dynamic>;
    await ApiClient.saveToken(data['token'] as String);
    await ApiClient.saveRole(data['user']?['role'] as String? ?? role);
    await NotificationService.syncToken();
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
    await NotificationService.syncToken();
    return data;
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post('/auth/logout', {});
    } finally {
      await ApiClient.clearToken();
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

  // ── Coach gym-request ──────────────────────────────────────
  static Future<Map<String, dynamic>> getCoachGymRequest() async {
    final response = await ApiClient.get('/coach/gym-request');
    return response['data'] as Map<String, dynamic>;
  }

  static Future<List<Map<String, dynamic>>> getAvailableGyms() async {
    final response = await ApiClient.get('/coach/available-gyms');
    final list = response['data'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>> submitGymRequest(int partnerGymId) async {
    final response = await ApiClient.post('/coach/gym-request', {
      'partner_gym_id': partnerGymId,
    });
    return response['data'] as Map<String, dynamic>;
  }

  static Future<void> withdrawGymRequest() async {
    await ApiClient.delete('/coach/gym-request');
  }
}
