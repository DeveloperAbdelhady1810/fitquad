class GymPlanModel {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;
  final int maxFreezeDays;

  const GymPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.maxFreezeDays,
  });

  factory GymPlanModel.fromJson(Map<String, dynamic> json) => GymPlanModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        durationDays: (json['duration_days'] as num?)?.toInt() ?? 30,
        features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
        maxFreezeDays: (json['max_freeze_days'] as num?)?.toInt() ?? 30,
      );
}

class GymPhotoModel {
  final int id;
  final String url;
  final bool isProfile;
  final int displayOrder;

  const GymPhotoModel({
    required this.id,
    required this.url,
    required this.isProfile,
    required this.displayOrder,
  });

  factory GymPhotoModel.fromJson(Map<String, dynamic> json) => GymPhotoModel(
        id: (json['id'] as num).toInt(),
        url: json['url'] as String? ?? '',
        isProfile: json['is_profile'] == true || json['is_profile'] == 1,
        displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      );
}

class PartnerGymModel {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String address;
  final String city;
  final String? phone;
  final List<String> amenities;
  final int capacity;
  final int attendanceToday;
  final String crowdLevel;
  final List<GymPlanModel> plans;
  final List<GymPhotoModel> photos;

  const PartnerGymModel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    required this.address,
    required this.city,
    this.phone,
    required this.amenities,
    required this.capacity,
    required this.attendanceToday,
    required this.crowdLevel,
    required this.plans,
    this.photos = const [],
  });

  String? get profilePhotoUrl {
    try {
      return photos.firstWhere((p) => p.isProfile).url;
    } catch (_) {
      return logo;
    }
  }

  List<GymPhotoModel> get galleryPhotos => photos.where((p) => !p.isProfile).toList();

  factory PartnerGymModel.fromJson(Map<String, dynamic> json) => PartnerGymModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        logo: json['logo'] as String?,
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        phone: json['phone'] as String?,
        amenities: (json['amenities'] as List?)?.map((e) => e.toString()).toList() ?? [],
        capacity: (json['capacity'] as num?)?.toInt() ?? 100,
        attendanceToday: (json['attendance_today'] as num?)?.toInt() ?? 0,
        crowdLevel: json['crowd_level'] as String? ?? 'quiet',
        plans: (json['plans'] as List?)
                ?.map((e) => GymPlanModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        photos: (json['photos'] as List?)
                ?.map((e) => GymPhotoModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
