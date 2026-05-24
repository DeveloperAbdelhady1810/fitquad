import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/enums/availability.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../generated/l10n.dart';
import '../../manager/onboarding_cubit.dart';

class StepSummary extends StatelessWidget {
  const StepSummary({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final s= S.of(context);

        if (state is! OnboardingChanged) {
          return const SizedBox();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              CircleAvatar(
                  backgroundColor: AppColors.emerald,
                  radius: 25.r,
                  child: Icon(Icons.check, color: AppColors.white, size: 25.sp,)
              ),
              vGap(10),
              Text(s.all_set , style: AppTextStyles.font16WhiteBold,),
              vGap(10),
              Text(s.plan_ready_message , style: AppTextStyles.font14GreyRegular, textAlign: TextAlign.center,),
              vGap(20),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: AppColors.secondary,
                    border: Border.all(color: AppColors.grey)
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row(title: s.goal, icon: Icons.change_circle_outlined, color: Colors.green, value: state.goal?.label(context)??''),
                    _row(title: s.frequency, icon: Icons.date_range, color: AppColors.blue, value:'${state.availability?.days.toString()} ${s.days_per_week}'),
                    _row(title: s.duration, icon: Icons.access_time, color: AppColors.purple, value:'${state.duration?.minutes.toString()} ${s.mins}'),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _row({required String title,required String value,required IconData icon,required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color,),
          hGap(5),
          Text(title , style: AppTextStyles.font14WhiteRegular,),
          hGap(5),
          Text(value,style: AppTextStyles.font14WhiteRegular,),
        ],
      ),
    );
  }
}
