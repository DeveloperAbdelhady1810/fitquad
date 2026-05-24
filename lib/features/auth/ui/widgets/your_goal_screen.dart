import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../../../core/enums/availability.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n.dart';
import '../../manager/onboarding_cubit.dart';

class StepGoal extends StatelessWidget {
  const StepGoal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final s= S.of(context);

        final selected = state is OnboardingChanged ? state.goal : null;

        return Padding(
          padding: const EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.emerald.withValues(alpha: 0.3),
                radius: 25.r,
                child: Icon(Icons.change_circle_outlined, color: AppColors.emerald, size: 25.sp,)
              ),
              vGap(10),
              Text(s.main_goal_question , style: AppTextStyles.font16WhiteBold,),
              vGap(10),
              Text(s.main_goal_description , style: AppTextStyles.font14GreyRegular,),
              vGap(15),
              ...GoalType.values.map((goal) {
                return Container(
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: AppColors.secondary,
                  ),
                  padding: EdgeInsets.all(16),
                  child: ListTile(
                    title: Text(
                      goal.label(context),
                      style: AppTextStyles.font16WhiteRegular,
                    ),
                    subtitle: Text(
                      goal.subTitle(context),
                      style: AppTextStyles.font14GreyRegular,
                    ),
                    trailing: selected == goal
                        ? Icon(Icons.circle, color: AppColors.white)
                        : Icon(Icons.circle_outlined, color: AppColors.grey),
                    onTap: () {
                      context.read<OnboardingCubit>().setGoal(goal);
                    },
                  ),
                );
              }),



            ],
          ),
        );
      },
    );
  }
}
