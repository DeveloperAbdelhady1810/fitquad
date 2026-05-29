import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';

import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:intl/intl.dart';

import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';

enum DayStatus { past, today, future }

DayStatus getDayStatus(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);

  if (day.isBefore(today)) return DayStatus.past;
  if (day.isAtSameMomentAs(today)) return DayStatus.today;
  return DayStatus.future;
}

DateTime _mondayOfCurrentWeek() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
}

List<Map<String, dynamic>> _defaultSchedule() => [
      {
        'title': 'Lower Body Strength',
        'subtitle': 'Squats, RDLs',
        'exercises': ['Squats', 'Romanian Deadlifts', 'Leg Press', 'Calf Raises'],
        'group': 'lower',
      },
      {
        'title': 'Upper Body Strength',
        'subtitle': 'Bench, Rows',
        'exercises': ['Bench Press', 'Barbell Row', 'Overhead Press', 'Pull-ups'],
        'group': 'upper',
      },
      {
        'title': 'Active Recovery',
        'subtitle': 'Yoga Flow',
        'exercises': [],
        'group': 'rest',
      },
      {
        'title': 'Lower Body Hypertrophy',
        'subtitle': 'Leg Press, Lunges',
        'exercises': ['Leg Press', 'Lunges', 'Leg Curl', 'Hip Thrust'],
        'group': 'lower',
      },
      {
        'title': 'Upper Body Power',
        'subtitle': 'Cleans, Shoulder',
        'exercises': ['Power Cleans', 'Shoulder Press', 'Lateral Raises', 'Tricep Dips'],
        'group': 'upper',
      },
      {
        'title': 'Cardio & Abs',
        'subtitle': 'HIIT Session',
        'exercises': ['HIIT Sprint x 8', 'Mountain Climbers', 'Plank 60s', 'Burpees x 10'],
        'group': 'cardio',
      },
      {
        'title': 'Rest Day',
        'subtitle': 'Full Recovery',
        'exercises': [],
        'group': 'rest',
      },
    ];

List<Map<String, dynamic>> _scheduleFromPlan(Map<String, dynamic> plan) {
  final days = plan['days'] as List?;
  if (days == null || days.isEmpty) return _defaultSchedule();
  return List.generate(7, (i) {
    if (i >= days.length) {
      return {
        'title': 'Rest Day',
        'subtitle': 'Recovery',
        'exercises': <String>[],
        'group': 'rest',
      };
    }
    try {
      final day = days[i] as Map<String, dynamic>;
      // API returns day_name; also support legacy title/type keys
      final title = day['day_name'] as String? ??
          day['title'] as String? ??
          day['muscle_group'] as String? ??
          day['type'] as String? ??
          'Training Day';
      // Support both {name} direct and {exercise: {name}} nested formats
      String exName(dynamic e) {
        if (e is Map) {
          return e['name'] as String? ??
              (e['exercise'] as Map?)?['name'] as String? ??
              '';
        }
        return e.toString();
      }
      final rawExercises = day['exercises'] as List?;
      final selectedExercises = (day['selectedExercises'] as List?)?.cast<String>();
      final exercises = rawExercises != null
          ? rawExercises.map(exName).where((n) => n.isNotEmpty).toList()
          : selectedExercises ?? <String>[];
      final subtitle = exercises.take(2).join(', ');
      final group = _inferGroup(title);
      return {
        'title': title,
        'subtitle': subtitle,
        'exercises': exercises,
        'group': group,
      };
    } catch (_) {
      return {
        'title': 'Rest Day',
        'subtitle': 'Recovery',
        'exercises': <String>[],
        'group': 'rest',
      };
    }
  });
}

String _inferGroup(String title) {
  final t = title.toLowerCase();
  if (t.contains('rest') || t.contains('recovery')) return 'rest';
  if (t.contains('cardio') || t.contains('hiit') || t.contains('run')) {
    return 'cardio';
  }
  if (t.contains('back') || t.contains('pull') || t.contains('row')) {
    return 'back';
  }
  if (t.contains('upper') ||
      t.contains('chest') ||
      t.contains('shoulder') ||
      t.contains('push')) {
    return 'upper';
  }
  return 'lower';
}

List<Color> _groupGradient(String group) {
  switch (group) {
    case 'upper':
      return [AppColors.blue, const Color(0xFF1a3a5c)];
    case 'lower':
      return [AppColors.teal, const Color(0xFF004d40)];
    case 'back':
      return [AppColors.purple, const Color(0xFF2d0050)];
    case 'cardio':
      return [AppColors.red, const Color(0xFF7f1800)];
    case 'rest':
    default:
      return [const Color(0xFF37474F), AppColors.secondary];
  }
}

IconData _groupIcon(String group) {
  switch (group) {
    case 'upper':
      return FontAwesomeIcons.dumbbell;
    case 'lower':
      return FontAwesomeIcons.personRunning;
    case 'back':
      return FontAwesomeIcons.arrowUp;
    case 'cardio':
      return FontAwesomeIcons.heartPulse;
    case 'rest':
    default:
      return FontAwesomeIcons.bed;
  }
}

void showWeekDialog(BuildContext context) {
  final cubit = context.read<MemberCubit>();
  final plan = cubit.workoutPlan;
  final schedule =
      plan != null ? _scheduleFromPlan(plan) : _defaultSchedule();
  final startOfWeek = _mondayOfCurrentWeek();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.secondary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _WeekBottomSheet(
      schedule: schedule,
      startOfWeek: startOfWeek,
    ),
  );
}

class _WeekBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> schedule;
  final DateTime startOfWeek;

  const _WeekBottomSheet({
    required this.schedule,
    required this.startOfWeek,
  });

  @override
  State<_WeekBottomSheet> createState() => _WeekBottomSheetState();
}

class _WeekBottomSheetState extends State<_WeekBottomSheet> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    // Default to today's index (0=Mon ... 6=Sun), or 0 if out of range
    final todayIndex = DateTime.now().weekday - 1;
    _selectedDay = todayIndex.clamp(0, 6);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDate =
        widget.startOfWeek.add(Duration(days: _selectedDay));
    final selectedStatus = getDayStatus(selectedDate);
    final selectedItem = widget.schedule[_selectedDay];
    final group = selectedItem['group'] as String? ?? 'lower';
    final exercises = (selectedItem['exercises'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    final completedDays = List.generate(7, (i) {
      final d = widget.startOfWeek.add(Duration(days: i));
      return getDayStatus(d) == DayStatus.past;
    }).where((v) => v).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
            child: Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
          ),
          // Week header
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Text(
              'Training Plan — Week of ${DateFormat('MMM d').format(widget.startOfWeek)}',
              style: AppTextStyles.font16WhiteBold,
              textAlign: TextAlign.center,
            ),
          ),
          // Day chips row
          SizedBox(
            height: 64.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 7,
              separatorBuilder: (_, __) => hGap(8),
              itemBuilder: (_, i) {
                final date = widget.startOfWeek.add(Duration(days: i));
                final status = getDayStatus(date);
                final isSelected = i == _selectedDay;

                Color chipBorder;
                Color chipText;
                Color chipBg;

                if (isSelected) {
                  chipBorder = AppColors.emerald;
                  chipText = AppColors.emerald;
                  chipBg = AppColors.emerald.withValues(alpha: 0.12);
                } else if (status == DayStatus.past) {
                  chipBorder = AppColors.grey.withValues(alpha: 0.3);
                  chipText = AppColors.grey;
                  chipBg = Colors.transparent;
                } else {
                  chipBorder = AppColors.grey.withValues(alpha: 0.5);
                  chipText = Colors.white;
                  chipBg = Colors.transparent;
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: Container(
                    width: 44.w,
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: chipBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayNames[i],
                          style: AppTextStyles.font14GreyRegular.copyWith(
                              color: chipText, fontSize: 11.sp),
                        ),
                        vGap(2),
                        Text(
                          DateFormat('d').format(date),
                          style: AppTextStyles.font16WhiteBold.copyWith(
                              color: chipText, fontSize: 14.sp),
                        ),
                        if (status == DayStatus.past)
                          Icon(Icons.check_circle,
                              color: AppColors.emerald, size: 10.r),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          vGap(12),
          // Day workout card
          Expanded(
            child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  // Gradient card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _groupGradient(group),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon + title
                        Row(
                          children: [
                            FaIcon(_groupIcon(group),
                                color: Colors.white, size: 28.r),
                            hGap(16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedItem['title'] as String? ??
                                        'Training Day',
                                    style:
                                        AppTextStyles.font16WhiteBold,
                                  ),
                                  if ((selectedItem['subtitle']
                                              as String?)
                                          ?.isNotEmpty ==
                                      true)
                                    Text(
                                      selectedItem['subtitle'] as String,
                                      style: AppTextStyles
                                          .font14GreyRegular
                                          .copyWith(
                                              color: Colors.white70,
                                              fontSize: 12.sp),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (exercises.isNotEmpty) ...[
                          vGap(16),
                          ...exercises.map(
                            (e) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  hGap(10),
                                  Text(
                                    e,
                                    style: AppTextStyles
                                        .font14WhiteRegular,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          vGap(16),
                          Text(
                            'Take it easy — rest and recover today.',
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        vGap(16),
                        CustomButton(
                          color: selectedStatus == DayStatus.today
                              ? AppColors.emerald
                              : AppColors.grey,
                          text: selectedStatus == DayStatus.past
                              ? s.view_summary
                              : selectedStatus == DayStatus.today
                                  ? s.start_workout
                                  : s.preview,
                          height: 44,
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                  vGap(16),
                  // Week progress bar
                  Container(
                    decoration: AppDecorations.containerDecoration,
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Weekly Progress',
                                style: AppTextStyles.font14GreyRegular),
                            Text(
                              '$completedDays/7 days completed',
                              style: AppTextStyles.font14GreyRegular
                                  .copyWith(color: AppColors.emerald),
                            ),
                          ],
                        ),
                        vGap(8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4.r),
                          child: LinearProgressIndicator(
                            value: completedDays / 7,
                            backgroundColor:
                                AppColors.grey.withValues(alpha: 0.2),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppColors.emerald),
                            minHeight: 8.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                  vGap(24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep showPartDialog for backward compatibility if referenced elsewhere
void showPartDialog(
    BuildContext context, DateTime date, String part, DayStatus status) {
  final s = S.of(context);
  final exercises = part.toLowerCase().contains('upper') ||
          part.toLowerCase().contains('chest') ||
          part.toLowerCase().contains('shoulder')
      ? ['Bench Press', 'Shoulder Press', 'Chest Fly', 'Tricep Pushdown']
      : part.toLowerCase().contains('rest') ||
              part.toLowerCase().contains('recovery')
          ? <String>[]
          : ['Squats', 'Lunges', 'Deadlift', 'Leg Press'];

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exercises.isEmpty ? part : '$part ${s.exercises}',
              style: AppTextStyles.font16WhiteBold,
            ),
            vGap(10),
            if (exercises.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Take it easy — rest and recover today.',
                  style: AppTextStyles.font14GreyRegular,
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...exercises.map((e) {
                final done = status == DayStatus.past;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: AppDecorations.containerDecoration.copyWith(
                      border: Border.all(
                        color: status == DayStatus.today
                            ? AppColors.emerald
                            : AppColors.grey,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          done
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: done ? AppColors.emerald : AppColors.grey,
                        ),
                        hGap(10),
                        Expanded(
                          child: Text(
                            e,
                            style: TextStyle(
                              color: done ? Colors.grey : Colors.white,
                              decoration:
                                  done ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            vGap(10),
            CustomButton(
              color: status == DayStatus.today
                  ? AppColors.emerald
                  : AppColors.grey,
              text: status == DayStatus.past
                  ? s.view_summary
                  : status == DayStatus.today
                      ? s.start_workout
                      : s.preview,
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    ),
  );
}
