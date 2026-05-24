import '../../../../core/services/api_client.dart';

class CoachRepository {
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await ApiClient.get('/coach/dashboard');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMembers() async {
    final res = await ApiClient.get('/coach/members');
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getSessions({String? date}) async {
    final res = await ApiClient.get('/coach/sessions',
        query: date != null ? {'date': date} : null);
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getPlanRequests() async {
    final res = await ApiClient.get('/coach/plan-requests');
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getMessages() async {
    final res = await ApiClient.get('/coach/messages');
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getMessageThread(int memberId) async {
    final res = await ApiClient.get('/coach/messages/$memberId');
    return res['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> sendMessage({
    required int receiverId,
    required String body,
  }) async {
    final res = await ApiClient.post('/coach/messages', {
      'receiver_id': receiverId,
      'body': body,
    });
    return res['data'] as Map<String, dynamic>;
  }
}
