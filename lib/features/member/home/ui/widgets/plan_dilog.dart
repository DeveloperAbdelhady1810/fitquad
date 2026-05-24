import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';

import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:intl/intl.dart';

import '../../../../../generated/l10n.dart';


enum DayStatus { past, today, future }

DayStatus getDayStatus(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);

  if (day.isBefore(today)) return DayStatus.past;
  if (day.isAtSameMomentAs(today)) return DayStatus.today;
  return DayStatus.future;
}

void showWeekDialog(BuildContext context) {
  final startOfWeek = DateTime.now();
  final List<Map<String, String>> schedule = [
    {'title': 'Lower Body Strength', 'subtitle': 'Squats, RDLs'},
    {'title': 'Upper Body Strength', 'subtitle': 'Bench, Rows'},
    {'title': 'Active Recovery', 'subtitle': 'Yoga Flow'},
    {'title': 'Lower Body Hypertrophy', 'subtitle': 'Leg Press, Lunges'},
    {'title': 'Upper Body Power', 'subtitle': 'Cleans, Shoulder'},
    {'title': 'Cardio & Abs', 'subtitle': 'HIIT Session'},
    {'title': 'Rest Day', 'subtitle': 'Full Recovery'},
  ];

  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(7, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final status = getDayStatus(date);
              final item = schedule[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: GestureDetector(
                  onTap: () {
                    showPartDialog(context, date, item['title']!, status);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: AppDecorations.containerDecoration.copyWith(
                      border: Border.all(
                        color: status == DayStatus.today? AppColors.emerald : AppColors.grey
                      )
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                decoration: status == DayStatus.past
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            Text(
                              DateFormat('dd').format(date),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: status == DayStatus.past
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: status == DayStatus.past
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              Text(
                                item['subtitle']!,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  decoration: status == DayStatus.past
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (status == DayStatus.today)
                          Icon(Icons.check_circle, color: Colors.greenAccent),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ),
  );
}

void showPartDialog(
    BuildContext context, DateTime date, String part, DayStatus status) {
  final s=S.of(context);
  final exercises = part.contains('Upper')
      ? ['Bench Press', 'Shoulder Press', 'Chest Fly']
      : ['Squats', 'Lunges', 'Deadlift'];

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
              '$part ${s.exercises}',
              style:AppTextStyles.font16WhiteBold,),
            vGap(10),

            ...exercises.map((e) {
              bool done = status == DayStatus.past;


              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: AppDecorations.containerDecoration.copyWith(

                    border:
                         Border.all(color: status == DayStatus.today? AppColors.emerald : AppColors.grey)

                  ),
                  child: Row(
                    children: [
                      Icon(
                        done ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: done
                            ? AppColors.emerald
                            : status == DayStatus.today
                            ? AppColors.grey
                            : Colors.grey[400],
                      ),
                      hGap(10),
                      Expanded(
                        child: Text(
                          e,
                          style: TextStyle(
                            color: done
                                ? Colors.grey
                                : status == DayStatus.today
                                ? Colors.white
                                : Colors.grey[400],
                            decoration: done ? TextDecoration.lineThrough : null,
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
                color:status == DayStatus.today? AppColors.emerald : AppColors.grey ,
                text:  status == DayStatus.past
                ? s.view_summary
                : status == DayStatus.today
                ? s.start_workout
                : s.preview, onPressed: ()=>context.pop()),

          ],
        ),
      ),
    ),
  );
}