import 'dart:io';

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
  static Future<List<dynamic>> getCoaches({String? search, String? source}) async {
    final query = <String, String>{};
    if (search != null) query['search'] = search;
    if (source != null) query['source'] = source;
    final res = await ApiClient.get('/member/coaches', query: query.isEmpty ? null : query);
    return res['data'] as List<dynamic>;
  }

  static Future<List<dynamic>> getMyCoaches() async {
    final res = await ApiClient.get('/member/my-coaches');
    return res['data'] as List<dynamic>;
  }

  // ── Gym / Branch ─────────────────────────────────────────────
  static Future<List<dynamic>> getBranches() async {
    final res = await ApiClient.get('/member/branches');
    return res['data'] as List<dynamic>;
  }

  static Future<void> assignBranch({
    String? branchId,
    String? partnerGymId,
    required String trainingMode,
  }) async {
    await ApiClient.post('/member/branch', {
      if (branchId != null) 'branch_id': int.tryParse(branchId),
      if (partnerGymId != null) 'partner_gym_id': int.tryParse(partnerGymId),
      'training_mode': trainingMode,
    });
  }

  static Future<Map<String, dynamic>> getBranchCrowding(String branchId) async {
    final res = await ApiClient.get('/member/branches/$branchId/crowding');
    return res['data'] as Map<String, dynamic>;
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

  static Future<Map<String, dynamic>> saveWorkoutPlan({
    required String title,
    required List<Map<String, dynamic>> days,
  }) async {
    final res = await ApiClient.post('/member/workout-plan', {
      'title': title,
      'days': days,
    });
    return res['data'] as Map<String, dynamic>? ?? {};
  }

  // ── Nutrition ────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getNutritionPlan() async {
    final res = await ApiClient.get('/member/nutrition-plan');
    return res['data']['nutrition_plan'] as Map<String, dynamic>?;
  }

  static Future<Map<String, dynamic>> saveNutritionPlan({
    required String title,
    required int dailyCalories,
    required String dietType,
  }) async {
    // Build a simple 4-meal structure based on the diet type
    final meals = [
      {'name': 'Breakfast', 'time_of_day': 'breakfast', 'food_items': []},
      {'name': 'Lunch',     'time_of_day': 'lunch',     'food_items': []},
      {'name': 'Dinner',    'time_of_day': 'dinner',    'food_items': []},
      {'name': 'Snack',     'time_of_day': 'snacks',    'food_items': []},
    ];
    final res = await ApiClient.post('/member/nutrition-plan', {
      'title'          : title,
      'daily_calories' : dailyCalories,
      'meals'          : meals,
    });
    return res['data'] as Map<String, dynamic>? ?? {};
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

  static Future<Map<String, dynamic>?> getFoodItemByBarcode(
      String barcode) async {
    final res = await ApiClient.get('/member/food-items/barcode',
        query: {'barcode': barcode});
    final data = res['data'];
    if (data == null) return null;
    return data as Map<String, dynamic>;
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

  static Future<Map<String, dynamic>> saveInBodyRecord(
      Map<String, dynamic> data) async {
    final res = await ApiClient.post('/member/inbody-records', data);
    return res['data'] as Map<String, dynamic>;
  }

  // ── Check-ins ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> checkIn({int? branchId}) async {
    final res = await ApiClient.post('/member/check-ins', {
      if (branchId != null) 'branch_id': branchId,
    });
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getCheckIns() async {
    final res = await ApiClient.get('/member/check-ins');
    final data = res['data'];
    // Paginated response has 'data' key inside
    if (data is Map && data['data'] is List) return data['data'] as List;
    if (data is List) return data;
    return [];
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

  // ── Gamification / Progress ──────────────────────────────────
  static Future<Map<String, dynamic>> getProgress() async {
    final res = await ApiClient.get('/member/progress');
    return res['data'] as Map<String, dynamic>;
  }

  // ── Progress Photos ──────────────────────────────────────────
  static Future<List<dynamic>> getProgressPhotos() async {
    final res = await ApiClient.get('/member/progress-photos');
    return res['data'] as List<dynamic>;
  }

  static Future<Map<String, dynamic>> uploadProgressPhoto({
    required File photo,
    String? notes,
    double? weight,
  }) async {
    final fields = <String, String>{};
    if (notes != null) fields['notes'] = notes;
    if (weight != null) fields['weight_at_time'] = weight.toString();
    final res = await ApiClient.uploadMultipart(
      '/member/progress-photos',
      photo,
      fileField: 'photo',
      fields: fields,
    );
    return res['data'] as Map<String, dynamic>;
  }

  static Future<void> deleteProgressPhoto(int id) async {
    await ApiClient.delete('/member/progress-photos/$id');
  }

  // ── Notifications ────────────────────────────────────────────
  static Future<List<dynamic>> getNotifications() async {
    final res = await ApiClient.get('/member/notifications');
    return (res['data']['data'] ?? res['data']) as List<dynamic>;
  }

  // ── Coach Messaging ──────────────────────────────────────────
  static Future<void> sendMessageToCoach(String body, {int? coachId}) async {
    await ApiClient.post('/member/messages', {
      'body': body,
      if (coachId != null) 'coach_id': coachId,
    });
  }

  static Future<List<dynamic>> getCoachThread() async {
    final res = await ApiClient.get('/member/messages');
    return res['data']['messages'] as List<dynamic>;
  }
}
