import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/enums/availability.dart';
import 'package:gym_app/core/skin/app_skin_cubit.dart';
import 'package:gym_app/core/theme/neo_theme.dart';

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
        final isNeo = context.watch<AppSkinCubit>().state == AppSkin.neo;

        // Always show the summary — use defaults from cubit if state is initial
        final onboarding = state is OnboardingChanged
            ? state
            : context.read<OnboardingCubit>().currentSummary;

        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children: [
              CircleAvatar(
                  backgroundColor: isNeo ? NeoColors.lime : AppColors.emerald,
                  radius: 25.r,
                  child: Icon(Icons.check, color: isNeo ? NeoColors.bg : AppColors.white, size: 25.sp,)
              ),
              vGap(10),
              Text(s.all_set , style: isNeo ? NeoTextStyles.headlineSm : AppTextStyles.font16WhiteBold,),
              vGap(10),
              Text(s.plan_ready_message , style: isNeo ? NeoTextStyles.bodySm : AppTextStyles.font14GreyRegular, textAlign: TextAlign.center,),
              vGap(20),
              Container(
                decoration: isNeo
                    ? BoxDecoration(color: NeoColors.surface, border: Border.all(color: NeoColors.outlineVariant))
                    : BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    color: AppColors.secondary,
                    border: Border.all(color: AppColors.grey)
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row(
                      isNeo: isNeo,
                      title: s.goal,
                      icon: Icons.change_circle_outlined,
                      color: isNeo ? NeoColors.lime : Colors.green,
                      value: onboarding.goals.isEmpty
                          ? '—'
                          : onboarding.goals.map((g) => g.label(context)).join(', '),
                    ),
                    _row(isNeo: isNeo, title: s.frequency, icon: Icons.date_range, color: isNeo ? NeoColors.cyan : AppColors.blue, value: '${onboarding.availability.days} ${s.days_per_week}'),
                    _row(isNeo: isNeo, title: s.duration, icon: Icons.access_time, color: isNeo ? NeoColors.magenta : AppColors.purple, value: '${onboarding.duration.minutes} ${s.mins}'),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _row({required String title,required String value,required IconData icon,required Color color, bool isNeo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color,),
          hGap(5),
          Text(title , style: isNeo ? NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface) : AppTextStyles.font14WhiteRegular,),
          hGap(5),
          Text(value,style: isNeo ? NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface) : AppTextStyles.font14WhiteRegular,),
        ],
      ),
    );
  }
}
