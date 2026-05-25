import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/ui/widgets/choose_coach_screen.dart';
import 'package:gym_app/features/member/train/widgets/design_manually_screen.dart';

import '../../../../core/enums/choose_coach.dart';
import '../../../../generated/l10n.dart';
import '../../home/manager/bottom_nav_bar_cubit.dart';

class TrainTab extends StatelessWidget {
  const TrainTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.lets_get_started,
          style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 22.sp),
        ),
        vGap(6),
        Text(
          s.choose_plan_method,
          style: AppTextStyles.font14GreyRegular,
        ),
        vGap(20),
        _TrainCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          ),
          icon: Icons.edit_note_outlined,
          title: s.design_manually,
          subtitle: s.select_days_exercises,
          onTap: () => context.push(DesignPlanManuallyScreen.routeName),
        ),
        vGap(12),
        _TrainCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF004D40), Color(0xFF00897B)],
          ),
          icon: Icons.smart_toy_outlined,
          title: s.ask_ai_coach,
          subtitle: s.instant_personalized_plan,
          onTap: () => context.read<BottomNavBarCubit>().changeIndex(2),
        ),
        vGap(12),
        _TrainCard(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
          ),
          icon: Icons.sports_gymnastics,
          title: s.real_coach,
          subtitle: s.request_professional_plan,
          onTap: () => context.push(
            ChooseCoachScreen.routeName,
            extra: ChooseCoachSource.train,
          ),
        ),
      ],
    );
  }
}

class _TrainCard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TrainCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 15.sp),
                  ),
                  vGap(4),
                  Text(
                    subtitle,
                    style: AppTextStyles.font14GreyRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.6), size: 16.r),
          ],
        ),
      ),
    );
  }
}
