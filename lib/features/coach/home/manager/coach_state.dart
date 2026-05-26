part of 'coach_cubit.dart';

@immutable
sealed class CoachState {}

final class CoachInitial extends CoachState {}

class CoachLoading extends CoachState {}

class CoachesLoaded extends CoachState {
  final List<SessionModel> sessions;
  final List<MemberModel> allMembers;
  final List<MemberModel> filteredMembers;
  final int todaySessions;
  final int activeMembers;
  final double monthlyEarnings;
  final double totalEarnings;
  final double rating;
  final List<Map<String, dynamic>> clientAlerts;

  CoachesLoaded({
    required this.sessions,
    required this.allMembers,
    required this.filteredMembers,
    this.todaySessions = 0,
    this.activeMembers = 0,
    this.monthlyEarnings = 0,
    this.totalEarnings = 0,
    this.rating = 0,
    this.clientAlerts = const [],
  });
}

class CoachError extends CoachState {
  final String message;

  CoachError(this.message);
}
