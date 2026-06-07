class GymGuestInvitationModel {
  final int id;
  final String code;
  final int gymId;
  final String? gymName;
  final DateTime visitDate;
  final DateTime? expiresAt;
  final String status;
  final bool isExpired;
  final bool canReschedule;
  final String? guestQrCode;
  final bool canUseForEntry;
  final Map<String, dynamic>? invitedMember;
  final Map<String, dynamic>? invitingMember;
  final DateTime? acceptedAt;
  final DateTime? usedAt;

  const GymGuestInvitationModel({
    required this.id,
    required this.code,
    required this.gymId,
    this.gymName,
    required this.visitDate,
    this.expiresAt,
    required this.status,
    required this.isExpired,
    required this.canReschedule,
    this.guestQrCode,
    required this.canUseForEntry,
    this.invitedMember,
    this.invitingMember,
    this.acceptedAt,
    this.usedAt,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isUsed => status == 'used';
  bool get isCancelled => status == 'cancelled';

  factory GymGuestInvitationModel.fromJson(Map<String, dynamic> json) {
    return GymGuestInvitationModel(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String? ?? '',
      gymId: (json['gym_id'] as num?)?.toInt() ?? 0,
      gymName: json['gym_name'] as String?,
      visitDate: DateTime.parse(json['visit_date'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      status: json['status'] as String? ?? 'pending',
      isExpired: json['is_expired'] == true,
      canReschedule: json['can_reschedule'] == true,
      guestQrCode: json['guest_qr_code'] as String?,
      canUseForEntry: json['can_use_for_entry'] == true,
      invitedMember: json['invited_member'] as Map<String, dynamic>?,
      invitingMember: json['inviting_member'] as Map<String, dynamic>?,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.tryParse(json['accepted_at'] as String)
          : null,
      usedAt: json['used_at'] != null
          ? DateTime.tryParse(json['used_at'] as String)
          : null,
    );
  }
}

class GymGuestPassQuotaModel {
  final int gymMembershipId;
  final int gymId;
  final String gymName;
  final int guestPassesTotal;
  final int guestPassesUsed;
  final int guestPassesRemaining;

  const GymGuestPassQuotaModel({
    required this.gymMembershipId,
    required this.gymId,
    required this.gymName,
    required this.guestPassesTotal,
    required this.guestPassesUsed,
    required this.guestPassesRemaining,
  });

  factory GymGuestPassQuotaModel.fromJson(Map<String, dynamic> json) {
    return GymGuestPassQuotaModel(
      gymMembershipId: (json['gym_membership_id'] as num).toInt(),
      gymId: (json['gym_id'] as num?)?.toInt() ?? 0,
      gymName: json['gym_name'] as String? ?? 'Gym',
      guestPassesTotal: (json['guest_passes_total'] as num?)?.toInt() ?? 0,
      guestPassesUsed: (json['guest_passes_used'] as num?)?.toInt() ?? 0,
      guestPassesRemaining:
          (json['guest_passes_remaining'] as num?)?.toInt() ?? 0,
    );
  }
}
