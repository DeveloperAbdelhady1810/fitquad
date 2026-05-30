import '../../../../core/services/api_client.dart';
import '../models/gym_membership_model.dart';
import '../models/partner_gym_model.dart';

class PartnerGymRepository {
  static Future<List<PartnerGymModel>> getGyms() async {
    final res = await ApiClient.get('/member/partner-gyms');
    final list = res['data'] as List;
    return list.map((e) => PartnerGymModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<Map<String, dynamic>> getGymDetail(int gymId) async {
    final res = await ApiClient.get('/member/partner-gyms/$gymId');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<List<GymMembershipModel>> getMemberships() async {
    final res = await ApiClient.get('/member/gym-memberships');
    final list = res['data'] as List;
    return list.map((e) => GymMembershipModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<GymMembershipModel> subscribe(int planId, double amountPaid) async {
    final res = await ApiClient.post('/member/gym-memberships', {
      'gym_subscription_plan_id': planId,
      'amount_paid': amountPaid,
    });
    return GymMembershipModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<GymMembershipModel> freeze(int membershipId) async {
    final res = await ApiClient.post('/member/gym-memberships/$membershipId/freeze', {});
    return GymMembershipModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<GymMembershipModel> unfreeze(int membershipId) async {
    final res = await ApiClient.post('/member/gym-memberships/$membershipId/unfreeze', {});
    return GymMembershipModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<void> cancel(int membershipId) async {
    await ApiClient.post('/member/gym-memberships/$membershipId/cancel', {});
  }

  static Future<Map<String, dynamic>> getSupportMessages(int gymId) async {
    final res = await ApiClient.get('/member/gym-support/$gymId');
    return res['data'] as Map<String, dynamic>;
  }

  static Future<void> sendSupportMessage(int gymId, String body) async {
    await ApiClient.post('/member/gym-support/$gymId', {'body': body});
  }

  static Future<Map<String, dynamic>> initiateGymPayment(int planId) async {
    final res = await ApiClient.post('/member/payments/initiate-gym', {
      'gym_subscription_plan_id': planId,
    });
    return res['data'] as Map<String, dynamic>;
  }

  static Future<GymMembershipModel> syncSubscription(int gymId, String externalId) async {
    final res = await ApiClient.post('/member/partner-gyms/$gymId/sync', {
      'external_id': externalId,
    });
    return GymMembershipModel.fromJson(res['data'] as Map<String, dynamic>);
  }
}
