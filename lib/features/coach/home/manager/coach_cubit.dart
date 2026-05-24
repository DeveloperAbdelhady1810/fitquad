import 'package:bloc/bloc.dart';
import 'package:gym_app/core/enums/member_type.dart';
import 'package:gym_app/features/member/data/models/member_model.dart';
import 'package:meta/meta.dart';

import '../../data/repositories/coach_repository.dart';
import '../data/models/session_model.dart';

part 'coach_state.dart';

class CoachCubit extends Cubit<CoachState> {
  CoachCubit() : super(CoachInitial());

  List<MemberModel> _allMembers = [];
  List<SessionModel> _sessions = [];

  Future<void> getCoachSessions(String coachId) async {
    emit(CoachLoading());
    try {
      final sessionsData = await CoachRepository.getSessions();
      final membersData = await CoachRepository.getMembers();

      _sessions = sessionsData
          .map((j) => SessionModel.fromJson(j as Map<String, dynamic>))
          .toList();

      _allMembers = membersData.map((j) {
        final map = j as Map<String, dynamic>;
        return MemberModel.fromJson(map);
      }).toList();

      emit(CoachesLoaded(
        sessions: _sessions,
        allMembers: _allMembers,
        filteredMembers: _allMembers,
      ));
    } catch (_) {
      emit(CoachesLoaded(
        sessions: _sessions,
        allMembers: _allMembers,
        filteredMembers: _allMembers,
      ));
    }
  }

  void filterMembers(MemberType? type) {
    if (state is! CoachesLoaded) return;

    final current = state as CoachesLoaded;

    final filtered = type == null
        ? current.allMembers
        : current.allMembers.where((m) => m.type == type).toList();

    emit(CoachesLoaded(
      sessions: current.sessions,
      allMembers: current.allMembers,
      filteredMembers: filtered,
    ));
  }
}
