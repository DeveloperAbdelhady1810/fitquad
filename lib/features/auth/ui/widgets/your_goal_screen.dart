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
        final s = S.of(context);
        final selectedGoals = state is OnboardingChanged ? state.goals : const <GoalType>{};

        return Padding(
          padding: const EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: AppColors.emerald.withValues(alpha: 0.3),
                  radius: 25.r,
                  child: Icon(Icons.change_circle_outlined, color: AppColors.emerald, size: 25.sp),
                ),
              ),
              vGap(10),
              Center(child: Text(s.main_goal_question, style: AppTextStyles.font16WhiteBold)),
              vGap(6),
              Center(
                child: Text(
                  s.main_goal_description,
                  style: AppTextStyles.font14GreyRegular,
                  textAlign: TextAlign.center,
                ),
              ),
              vGap(6),
              Center(
                child: Text(
                  'You can select multiple goals',
                  style: AppTextStyles.font14GreyRegular.copyWith(
                    color: AppColors.teal,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              vGap(15),
              ...GoalType.values.map((goal) {
                final isSelected = selectedGoals.contains(goal);
                return GestureDetector(
                  onTap: () => context.read<OnboardingCubit>().setGoal(goal),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.symmetric(vertical: 5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      color: isSelected
                          ? AppColors.teal.withValues(alpha: 0.12)
                          : AppColors.secondary,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.teal
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    child: Row(
                      children: [
                        // Checkbox
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 22.r,
                          height: 22.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(6.r),
                            color: isSelected ? AppColors.teal : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.teal : AppColors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 14.r)
                              : null,
                        ),
                        hGap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.label(context),
                                style: AppTextStyles.font16WhiteRegular.copyWith(
                                  color: isSelected ? AppColors.white : AppColors.white,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              vGap(2),
                              Text(
                                goal.subTitle(context),
                                style: AppTextStyles.font14GreyRegular,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
