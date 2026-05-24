part of 'coach_cubit.dart';

@immutable
sealed class CoachState {}

final class CoachInitial extends CoachState {}

class CoachLoading extends CoachState {}

class CoachesLoaded extends CoachState {
  final List<SessionModel> sessions;
  final List<MemberModel> allMembers;
  final List<MemberModel> filteredMembers;
  CoachesLoaded({
    required this.sessions,
    required this.allMembers,
    required this.filteredMembers,
  });
}

class CoachError extends CoachState {
  final String message;

  CoachError(this.message);
}
