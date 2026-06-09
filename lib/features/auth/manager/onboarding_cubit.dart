import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/availability.dart';
import '../../../core/services/api_client.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  final Set<GoalType> _goals = {};
  WorkoutDuration _duration = WorkoutDuration.min45;
  AvailabilityType _availability = AvailabilityType.fourDays;

  void setGoal(GoalType value) {
    // Toggle: add if not present, remove if already selected
    if (_goals.contains(value)) {
      _goals.remove(value);
    } else {
      _goals.add(value);
    }
    _emit();
  }

  void setDuration(WorkoutDuration value) {
    _duration = value;
    _emit();
  }

  void setAvailabilityFromSlider(double value) {
    _availability = AvailabilityType.values
        .firstWhere((e) => e.days == value.round(), orElse: () => AvailabilityType.fourDays);
    _emit();
  }

  Future<void> submit() async {
    if (_goals.isEmpty) return;
    try {
      final goalsList = _goals.map(_goalToApiValue).toList();
      await ApiClient.post('/auth/profile', {
        'goal':  goalsList.first,   // keep legacy single-goal for backend compat
        'goals': goalsList,         // new multi-goal array
        'availability_days': _availability.days,
        'workout_duration_mins': _duration.minutes,
      });
    } catch (_) {}
  }

  static String _goalToApiValue(GoalType goal) {
    switch (goal) {
      case GoalType.loseWeight:  return 'loss';
      case GoalType.buildMuscle: return 'gain';
      case GoalType.endurance:   return 'fit';
      case GoalType.flexibility: return 'maintain';
    }
  }

  void _emit() {
    emit(OnboardingChanged(
      goals: Set.from(_goals),
      duration: _duration,
      availability: _availability,
    ));
  }

  OnboardingChanged get currentSummary => OnboardingChanged(
        goals: Set.from(_goals),
        duration: _duration,
        availability: _availability,
      );
}
