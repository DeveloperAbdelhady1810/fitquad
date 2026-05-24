import 'package:flutter/material.dart';
import 'package:gym_app/core/theme/app_colors.dart';

import '../../../../generated/l10n.dart';
enum SessionStatus { upcoming, completed, ongoing }

extension SessionStatusX on SessionStatus {
  String label(BuildContext context) {
    switch (this) {
      case SessionStatus.upcoming:
        return S.of(context).upcoming;
      case SessionStatus.completed:
        return S.of(context).completed;
      case SessionStatus.ongoing:
        return S.of(context).ongoing;
    }
  }

  Color get color {
    switch (this) {
      case SessionStatus.upcoming:
        return Colors.blueGrey;
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.ongoing:
        return Colors.blueAccent;
    }
  }

  Color get backgroundColor {
  switch (this) {
  case SessionStatus.completed:
  return Color(0xff33343c);
  case SessionStatus.ongoing:
  return AppColors.secondary;
  case SessionStatus.upcoming:
  return AppColors.secondary.withValues(alpha: 0.3);
  }
}

  Color get borderColor {
  return this == SessionStatus.ongoing
  ? AppColors.blue
      : AppColors.grey;
}
  int get priority {
    switch (this) {
      case SessionStatus.completed:
        return 0;
      case SessionStatus.ongoing:
        return 1;
      case SessionStatus.upcoming:
        return 2;
    }
  }
bool get isDisabled => this == SessionStatus.completed;

bool get isHighlighted => this == SessionStatus.ongoing;
}
