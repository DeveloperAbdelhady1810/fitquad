part of 'onboarding_cubit.dart';

sealed class OnboardingState {}

final class OnboardingInitial extends OnboardingState {}

final class OnboardingChanged extends OnboardingState {
  final Set<GoalType> goals;
  final WorkoutDuration duration;
  final AvailabilityType availability;

  OnboardingChanged({
    Set<GoalType>? goals,
    this.duration = WorkoutDuration.min45,
    this.availability = AvailabilityType.fourDays,
  }) : goals = goals ?? const {};

  /// Convenience: the first selected goal (for backward-compat reads)
  GoalType? get goal => goals.isEmpty ? null : goals.first;
}
