import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/home/ui/widgets/week_summary_screen.dart';
import 'package:intl/intl.dart';

import '../../../../../core/widgets/custom_dropdown_menu.dart';
import '../../../../../generated/l10n.dart';
import '../../../data/models/exercise.dart';

class DaysContainersScreen extends StatefulWidget {
  final int days;
  const DaysContainersScreen({super.key, required this.days});

  @override
  State<DaysContainersScreen> createState() => _DaysContainersScreenState();
}

class _DaysContainersScreenState extends State<DaysContainersScreen> {
  late List<Map<String, dynamic>> daysData;

  @override
  void initState() {
    super.initState();
    daysData = List.generate(
      widget.days,
      (_) => {'exerciseType': null, 'exercises': <Exercise>[]},
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(s.create_your_plan, style: AppTextStyles.font16WhiteBold),
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.days,
        itemBuilder: (context, index) {
          final day = daysData[index];
          final currentDate = DateTime.now().add(Duration(days: index));
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: AppDecorations.containerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE').format(currentDate),
                  style: AppTextStyles.font16WhiteBold,
                ),
                vGap(10),

                CustomDropdown<String>(
                  items: exerciseMap.keys.toList(),
                  labelBuilder: (e) => e,
                  hint: day['exerciseType'] ?? 'Select Exercise Type',
                  value: day['exerciseType'],
                  onChanged: (value) {
                    setState(() {
                      day['exerciseType'] = value;
                      day['exercises'] = exerciseMap[value]!
                          .map((e) => Exercise(name: e.name))
                          .toList(); // reset selection
                    });
                  },
                ),

               vGap(10),
                if (day['exercises'].isNotEmpty)
                  ...day['exercises'].map<Widget>((ex) {
                    return CheckboxListTile(
                      value: ex.selected,
                      title: Text(ex.name, style: const TextStyle(color: Colors.white)),
                      onChanged: (val) {
                        setState(() {
                          ex.selected = val!;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.greenAccent,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          text: s.save_plan,
          onPressed: () {
            final weekPlan = daysData
                .map(
                  (day) => {
                'type': day['exerciseType'],
                'selectedExercises': (day['exercises'] as List<Exercise>)
                    .where((e) => e.selected)
                    .map((e) => e.name)
                    .toList(),
              },
            )
                .toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WeekSummaryScreen(
                  weekPlan: weekPlan,
                ),
              ),
            );
          },
        ),
      ),    );
  }
}
