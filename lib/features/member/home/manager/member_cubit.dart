import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/helpers/app_constants.dart';
import 'package:intl/intl.dart';

import '../../../../core/helpers/shared_pref_helper.dart';
import '../../data/models/coach_model.dart';
import '../../data/models/member_model.dart';
import '../../data/repositories/member_repository.dart';
import 'member_state.dart';

class MemberCubit extends Cubit<MemberState> {
  MemberCubit() : super(MemberLoading());

  /// Cached member data — survives MemberUpdated/MemberLoading emits.
  MemberModel? _cachedMember;
  MemberModel? get currentMember => _cachedMember;

  Map<String, dynamic>? workoutPlan;
  Map<String, dynamic>? nutritionPlan;
  String? todayWorkoutStatus; // null | 'done' | 'semi'
  List<double> weekCheckIns = [0, 0, 0, 0, 0, 0, 0]; // Mon–Sun
  Map<String, dynamic>? progressData; // streak, xp, level, badges
  bool showMilestoneCelebration = false;
  int? celebrationStreak;
  List<Map<String, dynamic>> myCoaches = []; // accepted/completed coach requests

  static String get _todayKey =>
      'workout_status_${DateFormat('yyyy-MM-dd').format(DateTime.now())}';

  Future<void> loadAll() async {
    await loadMember();
    final results = await Future.wait([
      MemberRepository.getWorkoutPlan().catchError((_) => null),
      MemberRepository.getNutritionPlan().catchError((_) => null),
      _loadWeekCheckIns().catchError((_) {}),
      MemberRepository.getProgress().catchError((_) => <String, dynamic>{}),
      MemberRepository.getMyCoaches().catchError((_) => <dynamic>[]),
    ]);
    workoutPlan   = results[0] as Map<String, dynamic>?;
    nutritionPlan = results[1] as Map<String, dynamic>?;
    progressData  = results[3] as Map<String, dynamic>?;
    myCoaches     = ((results[4] as List?) ?? []).cast<Map<String, dynamic>>();

    // Detect streak milestone to celebrate
    if (progressData != null) {
      final streak = (progressData!['streak_days'] as num?)?.toInt() ?? 0;
      final lastSeenKey = 'last_seen_streak';
      final lastSeen = (await SharedPrefHelper.getInt(lastSeenKey)) ?? 0;
      const milestones = [3, 7, 14, 30, 100];
      for (final m in milestones) {
        if (streak >= m && lastSeen < m) {
          showMilestoneCelebration = true;
          celebrationStreak = streak;
          break;
        }
      }
      await SharedPrefHelper.setData(lastSeenKey, streak);

      // Sync streak/xp/level into MemberModel if loaded
      final current = _cachedMember ?? (state is MemberLoaded ? (state as MemberLoaded).member : null);
      if (current != null) {
        _emitMemberLoaded(current.copyWith(
          streakDays: streak,
          xpPoints: (progressData!['xp_points'] as num?)?.toInt() ?? current.xpPoints,
          level: (progressData!['level'] as num?)?.toInt() ?? current.level,
        ));
      }
    }

    final saved = (await SharedPrefHelper.getString(_todayKey)) as String;
    todayWorkoutStatus = saved.isNotEmpty ? saved : null;
    if (_cachedMember != null) emit(MemberLoaded(_cachedMember!));
  }

  void clearMilestoneCelebration() {
    showMilestoneCelebration = false;
    celebrationStreak = null;
    // Re-emit MemberLoaded so cached member data is preserved in state
    if (_cachedMember != null) {
      emit(MemberLoaded(_cachedMember!));
    } else {
      emit(MemberUpdated());
    }
  }

  Future<void> _loadWeekCheckIns() async {
    final checkIns = await MemberRepository.getCheckIns();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final counts = List<double>.filled(7, 0);
    for (final ci in checkIns) {
      final raw = ci['checked_in_at'] as String?;
      if (raw == null) continue;
      final date = DateTime.tryParse(raw);
      if (date == null) continue;
      final diff = date.difference(weekStart).inDays;
      if (diff >= 0 && diff < 7) counts[diff]++;
    }
    weekCheckIns = counts;
  }

  Future<void> markWorkoutDone(String status) async {
    todayWorkoutStatus = status;
    await SharedPrefHelper.setData(_todayKey, status);
    emit(MemberUpdated());
  }

  Future<void> loadMember() async {
    try {
      emit(MemberLoading());
      final data = await MemberRepository.getDashboard();
      _cachedMember = MemberModel.fromJson(data);
      emit(MemberLoaded(_cachedMember!));
    } catch (e) {
      emit(const MemberError('Failed to load member'));
    }
  }

  Future<void> loadCoaches({String? source}) async {
    try {
      emit(MemberLoading());
      final data = await MemberRepository.getCoaches(source: source);
      final coaches = data.map((j) => CoachModel.fromJson(j as Map<String, dynamic>)).toList();
      emit(CoachLoaded(coaches));
    } catch (e) {
      emit(const MemberError('Failed to load coaches'));
    }
  }

  void _emitMemberLoaded(MemberModel member) {
    _cachedMember = member;
    emit(MemberLoaded(member));
  }

  void increaseWeight() {
    final current = _cachedMember;
    if (current == null) return;
    _emitMemberLoaded(current.copyWith(weight: (current.weight ?? 0) + 0.1));
  }

  void decreaseWeight() {
    final current = _cachedMember;
    if (current == null) return;
    _emitMemberLoaded(
      current.copyWith(weight: ((current.weight ?? 0) - 0.1).clamp(0, 500)),
    );
  }

  void updateWeight(double weight) {
    final current = _cachedMember;
    if (current == null) return;
    final newWeight = double.parse(weight.clamp(0, 500).toStringAsFixed(1));
    _emitMemberLoaded(current.copyWith(weight: newWeight));
  }

  void updateSleepHrs(double hours) {
    final current = _cachedMember;
    if (current == null) return;
    _emitMemberLoaded(current.copyWith(sleepHrs: hours));
  }

  void updateWaterL(double liters) {
    final current = _cachedMember;
    if (current == null) return;
    final newWater = double.parse(liters.clamp(0, 10).toStringAsFixed(1));
    _emitMemberLoaded(current.copyWith(waterL: newWater));
  }

  Future<void> saveDashboardToApi() async {
    final current = _cachedMember;
    if (current == null) return;
    try {
      await MemberRepository.updateDashboard({
        if (current.weight != null) 'current_weight': current.weight,
        if (current.waterL != null) 'water_liters': current.waterL,
        if (current.sleepHrs != null) 'sleep_hours': current.sleepHrs,
      });
    } catch (_) {}
  }

// ================= WORKOUT TIMER =================

  int currentExercise = 0;
  int totalExercises = 8;
  bool isWorkoutPaused = false;
  bool isRunning = false;

  int totalSeconds = 0;
  Timer? _timer;

  Future<void> restoreWorkout() async {
    currentExercise = await SharedPrefHelper.getInt(AppConstants.kWorkoutExerciseKey) ?? 0;
    // HomeTab._initWorkout() calls setState() after this, so no emit needed here.
    // Emitting MemberUpdated would destroy MemberLoaded state every time the tab is revisited.
  }

  String get totalTime {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void startWorkout() {
    if (isRunning) return;
    isRunning = true;
    isWorkoutPaused = false;
    _startTimer();
    emit(MemberUpdated());
  }

  void togglePause() {
    if (!isRunning) return;
    isWorkoutPaused = !isWorkoutPaused;
    if (isWorkoutPaused) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
    emit(MemberUpdated());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isWorkoutPaused) {
        totalSeconds++;
        emit(MemberUpdated());
      }
    });
  }

  void nextExercise() {
    if (currentExercise < totalExercises - 1) {
      currentExercise++;
      emit(MemberUpdated());
    }
  }

  void previousExercise() {
    if (currentExercise > 0) {
      currentExercise--;
      emit(MemberUpdated());
    }
  }

  void finishWorkout() {
    _timer?.cancel();
    isRunning = false;
    isWorkoutPaused = false;
    emit(MemberUpdated());
  }
}
