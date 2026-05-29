class CoachModel {
  final String id;
  final String name;
  final String jobTitle;
  final double price;
  final double rating;
  final int reviewsCount;
  final String bio;
  final String service;
  final String turnaround;
  final List<String>? sessionIds;
  final String? coachType;
  final String? branchId;
  final String? avatarUrl;
  final bool isSubscribed;

  CoachModel({
    required this.id,
    required this.name,
    required this.jobTitle,
    required this.price,
    required this.rating,
    required this.reviewsCount,
    required this.bio,
    required this.service,
    required this.turnaround,
    this.sessionIds,
    this.coachType,
    this.branchId,
    this.avatarUrl,
    this.isSubscribed = false,
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    return CoachModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      jobTitle: json['job_title'] as String? ?? json['specialization'] as String? ?? 'Personal Trainer',
      price: (json['price'] as num?)?.toDouble() ?? (json['price_per_session'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      bio: json['bio'] as String? ?? '',
      service: json['service'] as String? ?? 'Custom Plan',
      turnaround: json['turnaround'] as String? ?? '24-48 hrs',
      coachType: json['coach_type'] as String?,
      branchId: json['branch_id']?.toString(),
      avatarUrl: json['avatar_url'] as String?,
      isSubscribed: json['is_subscribed'] as bool? ?? false,
    );
  }
}