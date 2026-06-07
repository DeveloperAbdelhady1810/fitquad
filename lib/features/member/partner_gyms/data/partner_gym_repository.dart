import '../../../../core/services/api_client.dart';
import '../models/gym_class_booking_model.dart';
import '../models/gym_class_model.dart';
import '../models/gym_guest_invitation_model.dart';
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

  // ── Gym Classes ─────────────────────────────────────────────

  static Future<List<GymClassModel>> getGymClasses({int? gymId}) async {
    final query = gymId != null ? '?gym_id=$gymId' : '';
    final res = await ApiClient.get('/member/classes$query');
    final list = res['data'] as List;
    return list
        .map((e) => GymClassModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<GymClassBookingModel>> getMyClassBookings() async {
    final res = await ApiClient.get('/member/class-bookings');
    final list = res['data'] as List;
    return list
        .map((e) => GymClassBookingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Map<String, dynamic>> bookClass(int classId) async {
    final res = await ApiClient.post('/member/classes/$classId/book', {});
    return res['data'] as Map<String, dynamic>;
  }

  static Future<void> cancelClassBooking(int classId) async {
    await ApiClient.post('/member/classes/$classId/cancel', {});
  }

  // ── Invitations ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> getInvitations() async {
    final res = await ApiClient.get('/member/invitations');
    return res['data'] as Map<String, dynamic>;
  }

  // ── Guest Passes ─────────────────────────────────────────────

  static Future<
      ({
        List<GymGuestPassQuotaModel> memberships,
        List<GymGuestInvitationModel> invitations,
      })> getGuestInvitations() async {
    final res = await ApiClient.get('/member/guest-invitations');
    final data = res['data'] as Map<String, dynamic>;
    final memberships = (data['memberships'] as List? ?? [])
        .map((e) =>
            GymGuestPassQuotaModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final invitations = (data['invitations'] as List? ?? [])
        .map((e) =>
            GymGuestInvitationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return (memberships: memberships, invitations: invitations);
  }

  static Future<GymGuestInvitationModel> createGuestInvitation(
      int gymMembershipId, DateTime visitDate) async {
    final res = await ApiClient.post('/member/guest-invitations', {
      'gym_membership_id': gymMembershipId,
      'visit_date':
          '${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}',
    });
    return GymGuestInvitationModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<GymGuestInvitationModel> rescheduleGuestInvitation(
      int invitationId, DateTime visitDate) async {
    final res = await ApiClient.put(
        '/member/guest-invitations/$invitationId/reschedule', {
      'visit_date':
          '${visitDate.year.toString().padLeft(4, '0')}-${visitDate.month.toString().padLeft(2, '0')}-${visitDate.day.toString().padLeft(2, '0')}',
    });
    return GymGuestInvitationModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<void> cancelGuestInvitation(int invitationId) async {
    await ApiClient.delete('/member/guest-invitations/$invitationId');
  }

  static Future<GymGuestInvitationModel> redeemGuestInvitation(
      String code) async {
    final res = await ApiClient
        .post('/member/guest-invitations/redeem', {'code': code});
    return GymGuestInvitationModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<List<GymGuestInvitationModel>> getMyGuestPasses() async {
    final res = await ApiClient.get('/member/guest-passes');
    final list = res['data'] as List;
    return list
        .map((e) =>
            GymGuestInvitationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
