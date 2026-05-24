import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../generated/l10n.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AiAbbBar extends StatelessWidget {
  const AiAbbBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: EdgeInsets.all(16),
      color: AppColors.primary,
      child: ListTile(
        leading: CircleAvatar(
          radius: 25.r,
          backgroundColor: AppColors.emerald.withValues(alpha: 0.3),
          child: Icon(
            Icons.smart_toy_outlined,
            size: 30.sp,
            color: AppColors.teal,
          ),
        ),
        title: Text(s.ai_coach, style: AppTextStyles.font16GreyBold),
        subtitle: Text(
          s.your_personal_fitness_assistant,
          style: AppTextStyles.font14GreyRegular,
        ),
      ),

    );
  }
}
