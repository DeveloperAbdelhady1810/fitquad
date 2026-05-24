import '../../../../core/services/api_client.dart';

class MemberRepository {
  // ── Dashboard ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async {
    final res = await ApiClient.get('/member/dashboard');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateDashboard(
      Map<String, dynamic> data) async {
    final res = await ApiClient.put('/member/dashboard', data);
    return res['data'] as Map<String, dynamic>;
  }

  // ── Coaches ──────────────────────────────────────────────────
  static Future<List<dynamic>> getCoaches({String? search}) async {
    final res = await ApiClient.get('/member/coaches',
        query: search != null ? {'search': search} : null);
    return res['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> requestCoach({
    required int coachId,
    required String type,
    String? notes,
  }) async {
    final res = await ApiClient.post('/member/coach-requests', {
      'coach_id': coachId,
      'type': type,
      if (notes != null) 'notes': notes,
    });
    return res['data'] as Map<String, dynamic>;
  }

  // ── Workout ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getWorkoutPlan() async {
    final res = await ApiClient.get('/member/workout-plan');
    return res['data']['workout_plan'] as Map<String, dynamic>?;
  }

  static Future<List<dynamic>> getExercises({String? muscleGroup}) async {
    final res = await ApiClient.get('/member/exercises',
        query: muscleGroup != null ? {'muscle_group': muscleGroup} : null);
    return res['data'] is Map
        ? (res['data'] as Map).values.expand((v) => v as List).toList()
        : res['data'] as List<dynamic>;
  }

  // ── Nutrition ────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getNutritionPlan() async {
    final res = await ApiClient.get('/member/nutrition-plan');
    return res['data']['nutrition_plan'] as Map<String, dynamic>?;
  }

  static Future<List<dynamic>> getFoodItems({
    String? category,
    String? search,
  }) async {
    final query = <String, String>{};
    if (category != null) query['category'] = category;
    if (search != null) query['search'] = search;
    final res = await ApiClient.get('/member/food-items', query: query);
    return res['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> logMeal({
    required int foodItemId,
    required double quantity,
    required String mealType,
  }) async {
    final res = await ApiClient.post('/member/logged-meals', {
      'food_item_id': foodItemId,
      'quantity': quantity,
      'meal_type': mealType,
    });
    return res['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getLoggedMeals({String? date}) async {
    final res = await ApiClient.get('/member/logged-meals',
        query: date != null ? {'date': date} : null);
    return res['data'] as Map<String, dynamic>;
  }

  // ── InBody ───────────────────────────────────────────────────
  static Future<List<dynamic>> getInBodyRecords() async {
    final res = await ApiClient.get('/member/inbody-records');
    return res['data'] as List<dynamic>;
  }

  // ── Check-ins ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> checkIn({int? branchId}) async {
    final res = await ApiClient.post('/member/check-ins', {
      if (branchId != null) 'branch_id': branchId,
    });
    return res['data'] as Map<String, dynamic>;
  }

  // ── Sessions ─────────────────────────────────────────────────
  static Future<List<dynamic>> getSessions() async {
    final res = await ApiClient.get('/member/sessions');
    return res['data'] as List<dynamic>;
  }

  // ── Shop ─────────────────────────────────────────────────────
  static Future<List<dynamic>> getProducts({String? category}) async {
    final res = await ApiClient.get('/member/shop/products',
        query: category != null ? {'category': category} : null);
    return res['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> placeOrder({
    required List<Map<String, dynamic>> items,
    String? promoCode,
    String? shippingAddress,
  }) async {
    final res = await ApiClient.post('/member/shop/orders', {
      'items': items,
      if (promoCode != null) 'promo_code': promoCode,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
    });
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getOrders() async {
    final res = await ApiClient.get('/member/shop/orders');
    return res['data'] as List<dynamic>;
  }

  // ── AI Chat ──────────────────────────────────────────────────
  static Future<String> sendAiMessage(String message) async {
    final res = await ApiClient.post('/member/ai/chat', {'message': message});
    return res['data']['message'] as String;
  }

  static Future<List<dynamic>> getAiHistory() async {
    final res = await ApiClient.get('/member/ai/history');
    return res['data'] as List<dynamic>;
  }

  // ── Notifications ────────────────────────────────────────────
  static Future<List<dynamic>> getNotifications() async {
    final res = await ApiClient.get('/member/notifications');
    return (res['data']['data'] ?? res['data']) as List<dynamic>;
  }

  // ── Coach Messaging ──────────────────────────────────────────
  static Future<void> sendMessageToCoach(String body) async {
    await ApiClient.post('/member/messages', {'body': body});
  }

  static Future<List<dynamic>> getCoachThread() async {
    final res = await ApiClient.get('/member/messages');
    return res['data']['messages'] as List<dynamic>;
  }
}
