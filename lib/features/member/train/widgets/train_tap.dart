import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/ui/widgets/choose_coach_screen.dart';
import 'package:gym_app/features/member/train/widgets/design_manually_screen.dart';
import 'package:gym_app/features/member/train/widgets/workout_history_screen.dart';

import '../../../../core/enums/choose_coach.dart';
import '../../../../generated/l10n.dart';
import '../../home/manager/bottom_nav_bar_cubit.dart';
import '../../home/manager/member_cubit.dart';
import '../../home/manager/member_state.dart';

class TrainTab extends StatelessWidget {
  const TrainTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────
          Text(
            s.lets_get_started,
            style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 24.sp),
          ),
          vGap(4),
          Text(
            s.choose_plan_method,
            style: AppTextStyles.font14GreyRegular,
          ),
          vGap(20),

          // ── Weekly Stats Row ────────────────────────────────────
          BlocBuilder<MemberCubit, MemberState>(
            builder: (context, state) {
              final cubit = context.read<MemberCubit>();
              final totalCheckIns = cubit.weekCheckIns.fold(0.0, (a, b) => a + b).toInt();
              final hasPlan = cubit.workoutPlan != null;
              final status = cubit.todayWorkoutStatus;

              return Row(
                children: [
                  _StatBox(
                    value: '$totalCheckIns',
                    label: s.this_week,
                    icon: Icons.fitness_center,
                    color: AppColors.teal,
                  ),
                  hGap(10),
                  _StatBox(
                    value: hasPlan ? s.active : s.no_plan_yet,
                    label: s.plan,
                    icon: Icons.assignment_outlined,
                    color: hasPlan ? AppColors.emerald : AppColors.grey,
                  ),
                  hGap(10),
                  _StatBox(
                    value: status == 'done'
                        ? s.workout_done
                        : status == 'semi'
                            ? s.workout_partial
                            : '—',
                    label: s.today,
                    icon: status == 'done'
                        ? Icons.check_circle
                        : status == 'semi'
                            ? Icons.remove_circle_outline
                            : Icons.radio_button_unchecked,
                    color: status == 'done'
                        ? AppColors.emerald
                        : status == 'semi'
                            ? const Color(0xFFFFD700)
                            : AppColors.grey,
                  ),
                ],
              );
            },
          ),

          vGap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.how_to_train,
                style: AppTextStyles.font14GreyRegular.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 12.sp,
                  letterSpacing: 1.1,
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push(WorkoutHistoryScreen.routeName),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                icon: Icon(Icons.history, size: 16.r, color: AppColors.teal),
                label: Text(s.history,
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(color: AppColors.teal, fontSize: 12.sp)),
              ),
            ],
          ),
          vGap(12),

          // ── Option Cards ────────────────────────────────────────
          _TrainCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            ),
            icon: Icons.edit_note_outlined,
            title: s.design_manually,
            subtitle: s.select_days_exercises,
            badge: s.full_control,
            badgeColor: const Color(0xFF42A5F5),
            onTap: () => context.push(DesignPlanManuallyScreen.routeName),
          ),
          vGap(12),
          _TrainCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00695C), Color(0xFF26A69A)],
            ),
            icon: Icons.smart_toy_outlined,
            title: s.ask_ai_coach,
            subtitle: s.instant_personalized_plan,
            badge: s.instant,
            badgeColor: const Color(0xFF26A69A),
            onTap: () => context.read<BottomNavBarCubit>().changeIndex(2),
          ),
          vGap(12),
          _TrainCard(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
            ),
            icon: Icons.sports_gymnastics,
            title: s.real_coach,
            subtitle: s.request_professional_plan,
            badge: s.professional,
            badgeColor: const Color(0xFFAB47BC),
            onTap: () => context.push(
              ChooseCoachScreen.routeName,
              extra: ChooseCoachSource.train,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18.r),
            vGap(6),
            Text(value,
                style: AppTextStyles.font16WhiteBold
                    .copyWith(color: color, fontSize: 14.sp)),
            vGap(2),
            Text(label,
                style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _TrainCard extends StatelessWidget {
  final Gradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback onTap;

  const _TrainCard({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
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
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: badgeColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28.r),
            ),
            SizedBox(width: 16.w),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.font16WhiteBold
                              .copyWith(fontSize: 16.sp),
                        ),
                      ),
                      hGap(8),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          badge,
                          style: AppTextStyles.font14GreyRegular.copyWith(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  vGap(6),
                  Text(
                    subtitle,
                    style: AppTextStyles.font14GreyRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.7), size: 16.r),
          ],
        ),
      ),
    );
  }
}
