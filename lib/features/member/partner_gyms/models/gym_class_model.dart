class GymClassModel {
  final int id;
  final int partnerGymId;
  final int? coachId;
  final String title;
  final String category;
  final String? description;
  final String? instructorName;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? location;
  final bool isPaid;
  final double price;
  final bool isActive;
  // Computed by API for the current member
  final int spotsRemaining;
  final bool alreadyBooked;
  final int? myBookingId;
  final String? myBookingStatus;
  // Loaded relation
  final String? gymName;
  final String? gymCity;

  const GymClassModel({
    required this.id,
    required this.partnerGymId,
    this.coachId,
    required this.title,
    required this.category,
    this.description,
    this.instructorName,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.location,
    required this.isPaid,
    required this.price,
    required this.isActive,
    required this.spotsRemaining,
    required this.alreadyBooked,
    this.myBookingId,
    this.myBookingStatus,
    this.gymName,
    this.gymCity,
  });

  bool get isFull => spotsRemaining == 0;
  bool get isPast => endTime.isBefore(DateTime.now());

  factory GymClassModel.fromJson(Map<String, dynamic> json) {
    final gym = json['gym'] as Map<String, dynamic>?;
    return GymClassModel(
      id: (json['id'] as num).toInt(),
      partnerGymId: (json['partner_gym_id'] as num).toInt(),
      coachId: (json['coach_id'] as num?)?.toInt(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      description: json['description'] as String?,
      instructorName: json['instructor_name'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      capacity: (json['capacity'] as num?)?.toInt() ?? 20,
      location: json['location'] as String?,
      isPaid: json['is_paid'] == true || json['is_paid'] == 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      spotsRemaining: (json['spots_remaining'] as num?)?.toInt() ?? 0,
      alreadyBooked: json['already_booked'] == true,
      myBookingId: (json['my_booking_id'] as num?)?.toInt(),
      myBookingStatus: json['my_booking_status'] as String?,
      gymName: gym?['name'] as String?,
      gymCity: gym?['city'] as String?,
    );
  }
}
