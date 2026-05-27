import 'package:gym_app/core/services/api_client.dart';

class PaymentRepository {
  static Future<Map<String, dynamic>> initiateCoachPayment({
    required String coachId,
  }) async {
    final res = await ApiClient.post('/member/payments/initiate', {
      'coach_id': int.parse(coachId),
    });
    return res['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> initiateOrderPayment({
    required List<Map<String, dynamic>> items,
    String? promoCode,
    String? shippingAddress,
  }) async {
    final res = await ApiClient.post('/member/payments/initiate-order', {
      'items': items,
      if (promoCode != null) 'promo_code': promoCode,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
    });
    return res['data'] as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> calculateFee({
    required String coachId,
  }) async {
    final res = await ApiClient.get('/member/payments/fee',
        query: {'coach_id': coachId});
    return res['data'] as Map<String, dynamic>;
  }
}
