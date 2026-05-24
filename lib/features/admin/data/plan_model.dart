class PlanModel {
  final String? id;
  final List<String> access;
  final double price;
  final String name;
  final int active;
  final int durationDays;
  final bool isActive;

  PlanModel({
    this.id,
    required this.access,
    required this.price,
    required this.name,
    required this.active,
    this.durationDays = 30,
    this.isActive = true,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    final rawAccess = json['access'];
    List<String> access = [];
    if (rawAccess is List) {
      access = rawAccess.map((e) => e.toString()).toList();
    } else if (rawAccess is String) {
      access = [rawAccess];
    }

    return PlanModel(
      id: json['id']?.toString(),
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      durationDays: (json['duration_days'] as num?)?.toInt() ?? 30,
      active: (json['active_subscriptions_count'] as num?)?.toInt() ?? 0,
      access: access,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
