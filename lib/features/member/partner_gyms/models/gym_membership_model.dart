import 'partner_gym_model.dart';

class GymMembershipModel {
  final int id;
  final String? externalId;
  final PartnerGymModel? gym;
  final GymPlanModel? plan;
  final String startDate;
  final String endDate;
  final String status;
  final int daysRemaining;
  final String? freezeStartDate;
  final int totalFrozenDays;
  final double amountPaid;

  const GymMembershipModel({
    required this.id,
    this.externalId,
    this.gym,
    this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.daysRemaining,
    this.freezeStartDate,
    required this.totalFrozenDays,
    required this.amountPaid,
  });

  bool get isActive => status == 'active';
  bool get isFrozen => status == 'frozen';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';

  factory GymMembershipModel.fromJson(Map<String, dynamic> json) {
    final gymJson = json['gym'] as Map<String, dynamic>?;
    final planJson = json['plan'] as Map<String, dynamic>?;
    return GymMembershipModel(
      id: (json['id'] as num).toInt(),
      externalId: json['external_id'] as String?,
      gym: gymJson != null ? PartnerGymModel.fromJson(gymJson) : null,
      plan: planJson != null ? GymPlanModel.fromJson(planJson) : null,
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
      freezeStartDate: json['freeze_start_date'] as String?,
      totalFrozenDays: (json['total_frozen_days'] as num?)?.toInt() ?? 0,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
    );
  }
}
