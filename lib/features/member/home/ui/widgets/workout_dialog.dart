import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/home/ui/widgets/workout_page_view_dialog.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

Future<void> showWorkoutDialog(
  BuildContext context, {
  required PageController pageController,
}) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: context.read<MemberCubit>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: BlocBuilder<MemberCubit, MemberState>(
            builder: (context, state) {
              final s = S.of(context);
              final cubit = context.read<MemberCubit>();
              final plan = cubit.workoutPlan;

              String title = 'Today\'s Workout';
              String muscleGroup = 'Full Body';
              List<Map<String, dynamic>> exercises = [];

              if (plan != null) {
                try {
                  final now = DateTime.now();
                  final dayIndex = now.weekday - 1;
                  final days = plan['days'] as List?;
                  if (days != null && dayIndex < days.length) {
                    final today = days[dayIndex] as Map<String, dynamic>;
                    title = today['title'] as String? ??
                        today['muscle_group'] as String? ??
                        title;
                    muscleGroup = today['muscle_group'] as String? ?? muscleGroup;
                    final exList = today['exercises'] as List?;
                    if (exList != null) {
                      exercises = exList
                          .take(4)
                          .map((e) => e as Map<String, dynamic>)
                          .toList();
                    }
                  }
                } catch (_) {}
              }

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.containerDecoration.copyWith(
                  color: AppColors.primary,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48.r,
                          height: 48.r,
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.fitness_center,
                              color: AppColors.emerald, size: 24.r),
                        ),
                        hGap(14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTextStyles.font16WhiteBold),
                              Text(muscleGroup,
                                  style: AppTextStyles.font14GreyRegular
                                      .copyWith(color: AppColors.emerald)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: AppColors.grey, size: 20.r),
                        ),
                      ],
                    ),
                    vGap(16),
                    const Divider(),
                    vGap(8),
                    if (exercises.isNotEmpty) ...[
                      Text('Exercises', style: AppTextStyles.font14GreyRegular),
                      vGap(8),
                      ...exercises.map((ex) => _ExerciseRow(exercise: ex)),
                      vGap(8),
                    ] else ...[
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                color: AppColors.teal, size: 16.r),
                            hGap(6),
                            Text('45 min  •  8 exercises  •  ~320 kcal',
                                style: AppTextStyles.font14GreyRegular),
                          ],
                        ),
                      ),
                      vGap(8),
                    ],
                    const Divider(),
                    vGap(12),
                    CustomButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showWorkoutPageViewDialog(context);
                      },
                      text: s.start_workout,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

class _ExerciseRow extends StatelessWidget {
  final Map<String, dynamic> exercise;
  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final name = exercise['name'] as String? ?? 'Exercise';
    final sets = exercise['sets']?.toString() ?? '3';
    final reps = exercise['reps']?.toString() ?? '12';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.fitness_center,
                color: AppColors.teal, size: 16.r),
          ),
          hGap(10),
          Expanded(
            child: Text(name, style: AppTextStyles.font14WhiteRegular),
          ),
          Text('$sets × $reps',
              style:
                  AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
        ],
      ),
    );
  }
}
