import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/skin/app_skin_cubit.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/auth/manager/onboarding_cubit.dart';

import '../../../../generated/l10n.dart';

class StepAvailability extends StatelessWidget {
  const StepAvailability({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final availability = state is OnboardingChanged
            ? state.availability
            : null;
        final s = S.of(context);
        final isNeo = context.watch<AppSkinCubit>().state == AppSkin.neo;
        final accent = isNeo ? NeoColors.cyan : AppColors.blue;

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              CircleAvatar(
                backgroundColor: isNeo ? NeoColors.surface : AppColors.secondary,
                radius: 25.r,
                child: Icon(Icons.date_range, color: accent, size: 25.sp),
              ),
              vGap(10),
              Text(s.training_frequency, style: isNeo ? NeoTextStyles.headlineSm : AppTextStyles.font16WhiteBold),
              vGap(5),
              Text(s.training_question, style: isNeo ? NeoTextStyles.bodySm : AppTextStyles.font14GreyRegular),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.center,
                textBaseline: TextBaseline.alphabetic,
                children: [

                  Text(
                    (availability?.days ?? 4).toString(),
                    style: isNeo
                        ? NeoTextStyles.dataLg.copyWith(fontSize: 30.sp)
                        : AppTextStyles.font16WhiteBold.copyWith(
                      color: AppColors.babyBlue,
                      fontSize: 30.sp,
                    ),
                  ),

                  hGap(5),
                  Text(
                    s.days_per_week,
                    style: isNeo ? NeoTextStyles.bodySm : AppTextStyles.font14WhiteRegular,
                  ),
                ],
              ),

              Slider(
                activeColor: isNeo ? NeoColors.cyan : AppColors.emerald,
                min: 2,
                max: 6,
                divisions: 4,
                value: (availability?.days ?? 4).toDouble(),
                onChanged: (value) {
                  context.read<OnboardingCubit>().setAvailabilityFromSlider(
                    value,
                  );
                },
              ),
              Container(
                decoration: isNeo
                    ? BoxDecoration(color: NeoColors.surface, border: Border.all(color: NeoColors.outlineVariant))
                    : BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: AppColors.secondary,
                ),
                padding: EdgeInsets.all(16),
                child: Text(s.recommended_days, style: isNeo ? NeoTextStyles.bodySm : AppTextStyles.font14GreyRegular,),
              )
            ],
          ),
        );
      },
    );
  }
}
