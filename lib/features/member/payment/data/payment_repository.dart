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

  static Future<Map<String, dynamic>> calculateFee({
    required String coachId,
  }) async {
    final res = await ApiClient.get('/member/payments/fee',
        query: {'coach_id': coachId});
    return res['data'] as Map<String, dynamic>;
  }
}
