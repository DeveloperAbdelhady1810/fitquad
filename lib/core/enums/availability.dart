import 'package:flutter/material.dart';
import 'package:gym_app/generated/l10n.dart';

enum GoalType {
  buildMuscle,
  loseWeight,
  endurance,
  flexibility
}

enum WorkoutDuration {
  min30(30),
  min45(45),
  min60(60),
  min90(90);

  final int minutes;
  const WorkoutDuration(this.minutes);
}



enum AvailabilityType {
  oneDay(1),
  twoDays(2),
  threeDays(3),
  fourDays(4),
  fiveDays(5),
  sixDays(6),
  sevenDays(7);

  final int days;
  const AvailabilityType(this.days);
}

extension AvailabilityTypeX on AvailabilityType {
  String get title {
    return '$days';
  }
}

extension WorkoutDurationX on WorkoutDuration {
  String get title {
    return '$minutes min';
  }
}


extension GoalTypeX on GoalType {
  String label(BuildContext context) {
    switch (this) {
      case GoalType.buildMuscle:
        return S.of(context).build_muscle;
      case GoalType.loseWeight:
        return S.of(context).lose_weight;
      case GoalType.endurance:
        return S.of(context).endurance;
      case GoalType.flexibility:
        return S.of(context).flexibility;
    }
  }

  String subTitle(BuildContext context) {
    switch (this) {
      case GoalType.buildMuscle:
        return S.of(context).hypertrophy;
      case GoalType.loseWeight:
        return S.of(context).fat_loss_toning;
      case GoalType.endurance:
        return S.of(context).cardio_stamina;
      case GoalType.flexibility:
        return S.of(context).mobility_health;
    }
  }
}
