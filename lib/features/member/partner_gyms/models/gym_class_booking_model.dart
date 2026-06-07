import 'gym_class_model.dart';

class GymClassBookingModel {
  final int id;
  final int gymClassId;
  final int memberId;
  final String status;
  final DateTime? bookedAt;
  final GymClassModel? gymClass;

  const GymClassBookingModel({
    required this.id,
    required this.gymClassId,
    required this.memberId,
    required this.status,
    this.bookedAt,
    this.gymClass,
  });

  bool get isBooked => status == 'booked';
  bool get isCancelled => status == 'cancelled';

  factory GymClassBookingModel.fromJson(Map<String, dynamic> json) {
    final classJson = json['gym_class'] as Map<String, dynamic>?;
    return GymClassBookingModel(
      id: (json['id'] as num).toInt(),
      gymClassId: (json['gym_class_id'] as num).toInt(),
      memberId: (json['member_id'] as num).toInt(),
      status: json['status'] as String? ?? 'booked',
      bookedAt: json['booked_at'] != null
          ? DateTime.tryParse(json['booked_at'] as String)
          : null,
      gymClass: classJson != null ? GymClassModel.fromJson(classJson) : null,
    );
  }
}
