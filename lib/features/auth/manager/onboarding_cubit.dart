import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/availability.dart';
import '../../../core/services/api_client.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit() : super(OnboardingInitial());

  GoalType? _goal;
  WorkoutDuration? _duration;
  AvailabilityType? _availability;

  void setGoal(GoalType value) {
    _goal = value;
    _emit();
  }

  void setDuration(WorkoutDuration value) {
    _duration = value;
    _emit();
  }

  void setAvailabilityFromSlider(double value) {
    _availability = AvailabilityType.values
        .firstWhere((e) => e.days == value.round());
    _emit();
  }

  Future<void> submit() async {
    if (_goal == null) return;
    try {
      await ApiClient.post('/auth/profile', {
        'goal': _goalToApiValue(_goal!),
      });
    } catch (_) {}
  }

  static String _goalToApiValue(GoalType goal) {
    switch (goal) {
      case GoalType.loseWeight: return 'loss';
      case GoalType.buildMuscle: return 'gain';
      case GoalType.endurance: return 'fit';
      case GoalType.flexibility: return 'maintain';
    }
  }

  void _emit() {
    emit(OnboardingChanged(
      goal: _goal,
      duration: _duration,
      availability: _availability,
    ));
  }
}
