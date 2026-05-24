import '../../../core/services/api_client.dart';

class AdminRepository {
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await ApiClient.get('/admin/dashboard');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getMembers({String? search, String? status}) async {
    final query = <String, String>{};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (status != null) query['status'] = status;
    final res = await ApiClient.get('/admin/members', query: query);
    return (res['data']['data'] ?? res['data']) as List<dynamic>;
  }

  static Future<List<dynamic>> getCoaches() async {
    final res = await ApiClient.get('/admin/coaches');
    return (res['data']['data'] ?? res['data']) as List<dynamic>;
  }

  static Future<List<dynamic>> getSubscriptionPlans() async {
    final res = await ApiClient.get('/admin/subscription-plans');
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getOrders({String? status}) async {
    final res = await ApiClient.get('/admin/orders',
        query: status != null ? {'status': status} : null);
    return (res['data']['data'] ?? res['data']) as List<dynamic>;
  }

  static Future<List<dynamic>> getProducts() async {
    final res = await ApiClient.get('/admin/products');
    return (res['data']['data'] ?? res['data']) as List<dynamic>;
  }

  static Future<Map<String, dynamic>> getAnalytics() async {
    final res = await ApiClient.get('/admin/analytics');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getCheckIns({String? date}) async {
    final res = await ApiClient.get('/admin/check-ins',
        query: date != null ? {'date': date} : null);
    return (res['data']['data'] ?? res['data']) as List<dynamic>;
  }

  static Future<List<dynamic>> getStaff() async {
    final res = await ApiClient.get('/admin/staff');
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getPromoCodes() async {
    final res = await ApiClient.get('/admin/promo-codes');
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getAnnouncements() async {
    final res = await ApiClient.get('/admin/announcements');
    return res['data'] as List<dynamic>;
  }
}
