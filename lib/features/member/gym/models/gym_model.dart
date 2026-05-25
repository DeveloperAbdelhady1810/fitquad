class GymModel {
  final String id;
  final String name;
  final String? address;
  final String? city;
  final int capacity;

  const GymModel({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.capacity = 50,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) => GymModel(
        id: json['id']?.toString() ?? '',
        name: json['name'] as String? ?? '',
        address: json['address'] as String?,
        city: json['city'] as String?,
        capacity: (json['capacity'] as num?)?.toInt() ?? 50,
      );
}

class CrowdingInfo {
  final String branchId;
  final String branchName;
  final int checkIns;
  final int capacity;
  final int occupancyPct;
  final String level;

  const CrowdingInfo({
    required this.branchId,
    required this.branchName,
    required this.checkIns,
    required this.capacity,
    required this.occupancyPct,
    required this.level,
  });

  factory CrowdingInfo.fromJson(Map<String, dynamic> json) => CrowdingInfo(
        branchId: json['branch_id']?.toString() ?? '',
        branchName: json['branch_name'] as String? ?? '',
        checkIns: (json['check_ins'] as num?)?.toInt() ?? 0,
        capacity: (json['capacity'] as num?)?.toInt() ?? 50,
        occupancyPct: (json['occupancy_pct'] as num?)?.toInt() ?? 0,
        level: json['level'] as String? ?? 'quiet',
      );
}
