part of 'onboarding_cubit.dart';

sealed class OnboardingState {}

final class OnboardingInitial extends OnboardingState {}

final class OnboardingChanged extends OnboardingState {
  final GoalType? goal;
  final WorkoutDuration? duration;
  final AvailabilityType? availability;

  OnboardingChanged({
    this.goal,
    this.duration,
    this.availability,
  });
}
