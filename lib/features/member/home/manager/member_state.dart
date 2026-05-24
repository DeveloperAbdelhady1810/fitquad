import 'package:equatable/equatable.dart';
import 'package:gym_app/features/member/data/models/coach_model.dart';
import '../../data/models/member_model.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

class MemberLoading extends MemberState {}
class MemberUpdated extends MemberState {}
class MemberWorkoutUpdated extends MemberState {}

class MemberLoaded extends MemberState {
  final MemberModel member;

  const MemberLoaded(this.member);

  @override
  List<Object?> get props => [member];
}

class MemberError extends MemberState {
  final String message;

  const MemberError(this.message);

  @override
  List<Object?> get props => [message];
}

class CoachLoaded extends MemberState {
  final List<CoachModel> coaches;

  const CoachLoaded(this.coaches);

  @override
  List<Object?> get props => [coaches];
}

