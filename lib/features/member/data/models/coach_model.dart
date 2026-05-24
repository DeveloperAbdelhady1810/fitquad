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
  });

  factory CoachModel.fromJson(Map<String, dynamic> json) {
    final coach = json['coach'] ?? json;
    final user = json['user'] ?? {};
    return CoachModel(
      id: coach['id']?.toString() ?? '',
      name: user['name'] as String? ?? '',
      jobTitle: coach['specialization'] as String? ?? 'Personal Trainer',
      price: (coach['price_per_session'] as num?)?.toDouble() ?? 0,
      rating: (coach['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (coach['reviews_count'] as num?)?.toInt() ?? 0,
      bio: coach['bio'] as String? ?? '',
      service: 'Custom Plan',
      turnaround: coach['turnaround'] as String? ?? '24-48 hrs',
    );
  }
}