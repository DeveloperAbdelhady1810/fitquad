import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/skin/app_skin_cubit.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/theme/neo_theme.dart';

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
        final isNeo = context.watch<AppSkinCubit>().state == AppSkin.neo;
        final accent = isNeo ? NeoColors.cyan : AppColors.teal;
        final selectedGoals = state is OnboardingChanged ? state.goals : const <GoalType>{};

        return Padding(
          padding: const EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.3),
                  radius: 25.r,
                  child: Icon(Icons.change_circle_outlined, color: accent, size: 25.sp),
                ),
              ),
              vGap(10),
              Center(child: Text(s.main_goal_question, style: isNeo ? NeoTextStyles.headlineSm : AppTextStyles.font16WhiteBold)),
              vGap(6),
              Center(
                child: Text(
                  s.main_goal_description,
                  style: isNeo ? NeoTextStyles.bodySm : AppTextStyles.font14GreyRegular,
                  textAlign: TextAlign.center,
                ),
              ),
              vGap(6),
              Center(
                child: Text(
                  'You can select multiple goals',
                  style: (isNeo ? NeoTextStyles.bodySm : AppTextStyles.font14GreyRegular).copyWith(
                    color: accent,
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
                      borderRadius: isNeo ? BorderRadius.zero : BorderRadius.circular(14.r),
                      color: isSelected
                          ? accent.withValues(alpha: 0.12)
                          : (isNeo ? NeoColors.surface : AppColors.secondary),
                      border: Border.all(
                        color: isSelected
                            ? accent
                            : (isNeo ? NeoColors.outlineVariant : Colors.grey.withValues(alpha: 0.3)),
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
                            borderRadius: isNeo ? BorderRadius.zero : BorderRadius.circular(6.r),
                            color: isSelected ? accent : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? accent : (isNeo ? NeoColors.outline : AppColors.grey),
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: isNeo ? NeoColors.bg : Colors.white, size: 14.r)
                              : null,
                        ),
                        hGap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                goal.label(context),
                                style: isNeo
                                    ? NeoTextStyles.bodyLg.copyWith(
                                        color: NeoColors.onSurface,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                      )
                                    : AppTextStyles.font16WhiteRegular.copyWith(
                                  color: isSelected ? AppColors.white : AppColors.white,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              vGap(2),
                              Text(
                                goal.subTitle(context),
                                style: isNeo ? NeoTextStyles.bodySm : AppTextStyles.font14GreyRegular,
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
