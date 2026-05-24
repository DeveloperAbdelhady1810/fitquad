import '../../../core/services/api_client.dart';

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
    await ApiClient.saveRole(data['user']?['role'] as String? ?? 'member');
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
    await ApiClient.saveRole(data['user']?['role'] as String? ?? role);
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
}
