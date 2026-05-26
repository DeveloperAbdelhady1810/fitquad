import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../home/manager/member_cubit.dart';
import '../home/manager/member_state.dart';
import 'badges_screen.dart';

class StreakCard extends StatefulWidget {
  const StreakCard({super.key});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<MemberCubit>();
      if (cubit.showMilestoneCelebration) {
        _confetti.play();
        cubit.clearMilestoneCelebration();
        _showMilestoneDialog(cubit.celebrationStreak ?? 0);
      }
    });
  }

  void _showMilestoneDialog(int streak) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(28.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🔥', style: TextStyle(fontSize: 56.sp)),
              vGap(12),
              Text(
                '$streak-Day Streak!',
                style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 22.sp),
                textAlign: TextAlign.center,
              ),
              vGap(8),
              Text(
                'You\'re on fire! Keep showing up every day.',
                style: AppTextStyles.font14GreyRegular.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              vGap(20),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'KEEP IT GOING 💪',
                  style: AppTextStyles.font14WhiteRegular.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        if (state is! MemberLoaded) return const SizedBox.shrink();
        final member = state.member;
        final streak = member.streakDays;
        final xp     = member.xpPoints;
        final level  = member.level;

        // XP within current level bracket (0–99)
        final xpInLevel    = xp % 100;
        final nextMilestone = _nextStreakMilestone(streak);

        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Confetti
            ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [
                AppColors.teal, AppColors.emerald, Colors.amber, Colors.orange,
              ],
            ),

            // Card
            GestureDetector(
              onTap: () => context.push(BadgesScreen.routeName),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D3B2E), Color(0xFF1B5E20)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.emerald.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Flame + streak
                        Text(
                          streak > 0 ? '🔥' : '💤',
                          style: TextStyle(fontSize: 28.sp),
                        ),
                        hGap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                streak > 0
                                    ? '$streak-day streak!'
                                    : 'No streak yet — check in today!',
                                style: AppTextStyles.font16WhiteBold,
                              ),
                              if (nextMilestone != null)
                                Text(
                                  '${nextMilestone - streak} more days to reach $nextMilestone 🏆',
                                  style: AppTextStyles.font14GreyRegular
                                      .copyWith(fontSize: 11.sp),
                                ),
                            ],
                          ),
                        ),
                        // Level badge
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                                color: AppColors.teal.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'Lvl $level',
                            style: AppTextStyles.font14GreyRegular.copyWith(
                              color: AppColors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    vGap(10),
                    // XP progress bar
                    Row(
                      children: [
                        Text(
                          'XP $xp',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp),
                        ),
                        hGap(8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: xpInLevel / 100,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.emerald),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        hGap(8),
                        Text(
                          '${100 - xpInLevel} to next lvl',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  int? _nextStreakMilestone(int current) {
    for (final m in [3, 7, 14, 30, 100]) {
      if (current < m) return m;
    }
    return null;
  }
}
