import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../../../../generated/l10n.dart';

class WeekSummaryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> weekPlan;

  const WeekSummaryScreen({super.key, required this.weekPlan});
  static const String routeName = '/week-summary';

  @override
  State<WeekSummaryScreen> createState() => _WeekSummaryScreenState();
}

class _WeekSummaryScreenState extends State<WeekSummaryScreen> {
  int selectedDayIndex = 0;

  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayFull = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  late List<Map<String, dynamic>> fullWeekPlan;

  @override
  void initState() {
    super.initState();
    fullWeekPlan = List.generate(
      7,
      (i) => i < widget.weekPlan.length
          ? widget.weekPlan[i]
          : {'type': null, 'selectedExercises': <String>[]},
    );
  }

  bool get _isRestDay {
    final day = fullWeekPlan[selectedDayIndex];
    final exercises = (day['selectedExercises'] as List?)?.cast<String>() ?? [];
    return exercises.isEmpty;
  }

  String get _dayLabel {
    final day = fullWeekPlan[selectedDayIndex];
    final type = day['type'] as String?;
    if (type != null && type.isNotEmpty) return type;
    return _isRestDay ? 'Rest Day' : 'Training Day';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final day = fullWeekPlan[selectedDayIndex];
    final exercises = (day['selectedExercises'] as List?)?.cast<String>() ?? [];
    final totalExercises = fullWeekPlan
        .where((d) => ((d['selectedExercises'] as List?)?.isNotEmpty ?? false))
        .length;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.custom_plan, style: AppTextStyles.font16WhiteBold),
            Text(
              '$totalExercises training days this week',
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Day selector ─────────────────────────────────────────
          Container(
            height: 72.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, i) {
                final isSelected = i == selectedDayIndex;
                final hasExercises = ((fullWeekPlan[i]['selectedExercises'] as List?)?.isNotEmpty ?? false);
                return GestureDetector(
                  onTap: () => setState(() => selectedDayIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52.w,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppColors.teal, Color(0xFF00897B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : AppColors.secondary,
                      borderRadius: BorderRadius.circular(14.r),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: hasExercises
                                  ? AppColors.teal.withValues(alpha: 0.4)
                                  : Colors.transparent,
                            ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekDays[i],
                          style: AppTextStyles.font14GreyRegular.copyWith(
                            color: isSelected
                                ? Colors.white
                                : hasExercises
                                    ? AppColors.teal
                                    : AppColors.grey,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11.sp,
                          ),
                        ),
                        vGap(4),
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasExercises
                                ? (isSelected ? Colors.white : AppColors.teal)
                                : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Day header card ──────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                gradient: _isRestDay
                    ? LinearGradient(
                        colors: [
                          Colors.grey.shade800,
                          Colors.grey.shade700,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRestDay
                          ? Icons.self_improvement_outlined
                          : Icons.fitness_center,
                      color: Colors.white,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dayFull[selectedDayIndex],
                          style: AppTextStyles.font14GreyRegular.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12.sp,
                          ),
                        ),
                        vGap(2),
                        Text(
                          _dayLabel,
                          style: AppTextStyles.font16WhiteBold,
                        ),
                      ],
                    ),
                  ),
                  if (!_isRestDay)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '${exercises.length} exercises',
                        style: AppTextStyles.font14GreyRegular.copyWith(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          vGap(12),

          // ── Exercise list / Rest state ───────────────────────────
          Expanded(
            child: _isRestDay
                ? _RestDayView()
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => vGap(8),
                    itemBuilder: (context, i) => _ExerciseRow(
                      index: i + 1,
                      name: exercises[i],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise row card ─────────────────────────────────────────────────────────

class _ExerciseRow extends StatelessWidget {
  final int index;
  final String name;

  const _ExerciseRow({required this.index, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: AppTextStyles.font14WhiteRegular.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.font16WhiteRegular.copyWith(fontSize: 14.sp),
            ),
          ),
          Icon(Icons.fitness_center, color: AppColors.grey, size: 16.r),
        ],
      ),
    );
  }
}

// ── Rest day placeholder ──────────────────────────────────────────────────────

class _RestDayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.self_improvement_outlined,
              color: AppColors.grey, size: 64.r),
          vGap(16),
          Text(
            'Rest Day',
            style: AppTextStyles.font16WhiteBold
                .copyWith(color: AppColors.grey),
          ),
          vGap(8),
          Text(
            'Recovery is part of the plan.\nStretch, sleep well, and recharge.',
            style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 13.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
