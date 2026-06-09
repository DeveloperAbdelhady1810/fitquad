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
import '../../../data/repositories/member_repository.dart';

class DaysContainersScreen extends StatefulWidget {
  final int days;
  final String planTitle;
  const DaysContainersScreen({super.key, required this.days, this.planTitle = 'My Custom Plan'});

  @override
  State<DaysContainersScreen> createState() => _DaysContainersScreenState();
}

class _DaysContainersScreenState extends State<DaysContainersScreen> {
  late List<Map<String, dynamic>> daysData;
  bool _saving = false;

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
          text: _saving ? 'Saving…' : s.save_plan,
          onPressed: _saving
              ? null
              : () async {
                  // Build the week-plan for summary view
                  final weekPlan = daysData.map((day) => {
                    'type': day['exerciseType'],
                    'selectedExercises': (day['exercises'] as List<Exercise>)
                        .where((e) => e.selected)
                        .map((e) => e.name)
                        .toList(),
                  }).toList();

                  // Build API payload — each day with its exercises by name
                  final apiDays = daysData.asMap().entries.map((entry) {
                    final i = entry.key;
                    final day = entry.value;
                    final exercises = (day['exercises'] as List<Exercise>)
                        .where((e) => e.selected)
                        .map((e) => {'name': e.name})
                        .toList();
                    return {
                      'day_name'  : DateFormat('EEE').format(DateTime.now().add(Duration(days: i))),
                      'exercises' : exercises,
                    };
                  }).toList();

                  // Skip save if no exercises selected in any day
                  final hasAny = apiDays.any((d) => (d['exercises'] as List).isNotEmpty);
                  if (!hasAny) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select at least one exercise.')),
                    );
                    return;
                  }

                  setState(() => _saving = true);
                  try {
                    await MemberRepository.saveWorkoutPlan(
                      title: widget.planTitle,
                      days: apiDays.cast<Map<String, dynamic>>(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plan saved!'),
                          backgroundColor: Color(0xFF00a689),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeekSummaryScreen(weekPlan: weekPlan),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
        ),
      ),
    );
  }
}
