import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
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

  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late List<Map<String, dynamic>> fullWeekPlan;

  @override
  void initState() {
    super.initState();
    fullWeekPlan = List.generate(
      7,
      (index) => index < widget.weekPlan.length
          ? widget.weekPlan[index]
          : {'type': null, 'selectedExercises': <String>[]},
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final day = fullWeekPlan[selectedDayIndex];
    final exercises = (day['selectedExercises'] as List<String>? ?? []);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              //todo -------------------
            },
            icon: Icon(Icons.refresh, color: AppColors.white),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.custom_plan, style: AppTextStyles.font16WhiteBold),
            const SizedBox(height: 4),
            Text(s.target_custom, style: AppTextStyles.font14WhiteRegular),
          ],
        ),
      ),
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          Container(
            decoration: AppDecorations.containerDecoration,
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDays.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedDayIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.greenAccent : Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      weekDays[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: exercises.isNotEmpty
                  ? ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '- ${exercises[index]}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        'No exercises selected',
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
