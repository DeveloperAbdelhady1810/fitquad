import 'package:gym_app/core/enums/member_type.dart';

enum MemberStatus { active, inactive, frozen, expiring }

class MemberModel {
  final String? id;
  final String? name;
  final double? weight;
  final double? sleepHrs;
  final double? waterL;
  final List<String>? sessionIds;
  final MemberType? type;
  final double? age;
  final String? plan;
  final MemberStatus? status;
  final String? lastCheckIn;
  final String? branchId;
  final String? trainingMode;
  final int streakDays;
  final int xpPoints;
  final int level;
  final String? referralCode;
  final int loyaltyPoints;
  final String? avatarUrl;

  MemberModel({
    this.id,
    this.name,
    this.weight,
    this.sleepHrs,
    this.waterL,
    this.sessionIds,
    this.type,
    this.age,
    this.plan,
    this.status,
    this.lastCheckIn,
    this.branchId,
    this.trainingMode,
    this.streakDays = 0,
    this.xpPoints = 0,
    this.level = 1,
    this.referralCode,
    this.loyaltyPoints = 0,
    this.avatarUrl,
  });

  bool get needsGymSelection => trainingMode == null;

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final member = (json['member'] as Map<String, dynamic>?) ?? json;
    // user is nested inside member (loaded via ->load('user') in backend)
    final user = (member['user'] as Map<String, dynamic>?) ??
        (json['user'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    return MemberModel(
      id: member['id']?.toString(),
      name: (user['name'] as String?)?.isNotEmpty == true
          ? user['name'] as String
          : (member['name'] as String?),
      weight: (member['current_weight'] as num?)?.toDouble(),
      sleepHrs: (member['sleep_hours'] as num?)?.toDouble(),
      waterL: (member['water_liters'] as num?)?.toDouble(),
      type: _goalToType(member['goal'] as String?),
      status: _parseStatus(member['status'] as String?),
      branchId: member['branch_id']?.toString(),
      trainingMode: member['training_mode'] as String?,
      streakDays: (member['streak_days'] as num?)?.toInt() ?? 0,
      xpPoints: (member['xp_points'] as num?)?.toInt() ?? 0,
      level: (member['level'] as num?)?.toInt() ?? 1,
      referralCode: member['referral_code'] as String?,
      loyaltyPoints: (member['loyalty_points'] as num?)?.toInt() ?? 0,
      // user['avatar_url'] covers the member's own dashboard (nested user object)
      // member/json['avatar_url'] covers the flat map from the coach's members list
      avatarUrl: user['avatar_url'] as String? ??
          member['avatar_url'] as String? ??
          json['avatar_url'] as String?,
    );
  }

  static MemberType? _goalToType(String? goal) {
    switch (goal) {
      case 'loss': return MemberType.loss;
      case 'fit': return MemberType.fit;
      case 'low': return MemberType.low;
      default: return MemberType.neww;
    }
  }

  static MemberStatus? _parseStatus(String? s) {
    switch (s) {
      case 'active': return MemberStatus.active;
      case 'inactive': return MemberStatus.inactive;
      case 'frozen': return MemberStatus.frozen;
      case 'expiring': return MemberStatus.expiring;
      default: return null;
    }
  }

  MemberModel copyWith({
    String? id,
    String? name,
    double? weight,
    double? sleepHrs,
    double? waterL,
    List<String>? sessionIds,
    MemberType? type,
    double? age,
    String? plan,
    MemberStatus? status,
    String? lastCheckIn,
    String? branchId,
    String? trainingMode,
    int? streakDays,
    int? xpPoints,
    int? level,
    String? referralCode,
    int? loyaltyPoints,
    String? avatarUrl,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      sleepHrs: sleepHrs ?? this.sleepHrs,
      waterL: waterL ?? this.waterL,
      sessionIds: sessionIds ?? this.sessionIds,
      type: type ?? this.type,
      age: age ?? this.age,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      branchId: branchId ?? this.branchId,
      trainingMode: trainingMode ?? this.trainingMode,
      streakDays: streakDays ?? this.streakDays,
      xpPoints: xpPoints ?? this.xpPoints,
      level: level ?? this.level,
      referralCode: referralCode ?? this.referralCode,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
