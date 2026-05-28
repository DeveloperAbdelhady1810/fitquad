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
      final results = await Future.wait([
        CoachRepository.getSessions(),
        CoachRepository.getMembers(),
        CoachRepository.getDashboard(),
      ]);

      final sessionsData = results[0] as List<dynamic>;
      final membersData = results[1] as List<dynamic>;
      final dashboard = results[2] as Map<String, dynamic>;

      _sessions = sessionsData
          .map((j) => SessionModel.fromJson(j as Map<String, dynamic>))
          .toList();

      _allMembers = membersData.map((j) {
        final map = j as Map<String, dynamic>;
        return MemberModel.fromJson(map);
      }).toList();

      final alerts = (dashboard['client_alerts'] as List? ?? [])
          .map((a) => Map<String, dynamic>.from(a as Map))
          .toList();

      // today_sessions is a list of session objects from backend
      final todayRaw = dashboard['today_sessions'];
      final todayCount = todayRaw is List
          ? todayRaw.length
          : (todayRaw as num?)?.toInt() ?? 0;

      emit(CoachesLoaded(
        sessions: _sessions,
        allMembers: _allMembers,
        filteredMembers: _allMembers,
        todaySessions: todayCount,
        activeMembers: (dashboard['active_members'] as num?)?.toInt() ??
            _allMembers.length,
        monthlyEarnings:
            (dashboard['monthly_earnings'] as num?)?.toDouble() ?? 0,
        totalEarnings: (dashboard['total_earnings'] as num?)?.toDouble() ?? 0,
        rating: (dashboard['rating'] as num?)?.toDouble() ?? 0,
        clientAlerts: alerts,
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
