import 'package:gym_app/features/member/data/models/member_model.dart';

import '../../manager/status_ext.dart';

class SessionModel {
  final String? id;
  MemberModel? memberModel;
  DateTime? startTime;
  DateTime? endTime;
  String? location;
  SessionStatus? status;
  String? type;
  final String? coachId;
  final String? memberId;

  SessionModel({
    this.memberModel,
    this.endTime,
    this.startTime,
    this.status,
    this.location,
    this.type,
    this.coachId,
    this.memberId,
    this.id,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id']?.toString(),
      type: json['type'] as String?,
      location: json['location'] as String?,
      startTime: json['start_time'] != null ? DateTime.tryParse(json['start_time'] as String) : null,
      endTime: json['end_time'] != null ? DateTime.tryParse(json['end_time'] as String) : null,
      coachId: json['coach_id']?.toString(),
      memberId: json['member_id']?.toString(),
      status: _parseStatus(json['status'] as String?),
    );
  }

  static SessionStatus _parseStatus(String? s) {
    switch (s) {
      case 'completed': return SessionStatus.completed;
      case 'ongoing': return SessionStatus.ongoing;
      default: return SessionStatus.upcoming;
    }
  }
}
