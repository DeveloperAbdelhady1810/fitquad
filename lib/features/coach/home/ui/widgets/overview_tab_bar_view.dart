import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';

import '../../../../../generated/l10n.dart';
import '../../../../member/data/models/member_model.dart';


class OverviewTabBarView extends StatelessWidget {
  final MemberModel member;

  const OverviewTabBarView({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final s= S.of(context);
    final bottomTitles = {1: 'Sat', 2: 'Sun', 3: 'Mon', 4: 'Tue'};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildContainer(title: 'Training', duration: '3h', subtitle: 'Strength'),
          vGap(10),
          buildContainer(title: 'Nutrition', duration: '2 meals', subtitle: 'Balanced'),
          vGap(10),
          // Line chart
          Container(
            decoration: AppDecorations.containerDecoration,
            padding: const EdgeInsets.all(10),
            height: 200,
            child: LineChart(LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(1, 2),
                    FlSpot(2, 4),
                    FlSpot(3, 3),
                    FlSpot(4, 5),
                  ],
                  isCurved: true,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                ),
              ],
              minX: 1,
              maxX: 4,
              minY: 0,
              maxY: 6,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      return Text(
                        bottomTitles[value.toInt()] ?? '',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
            )),
          ),
          vGap(10),
          Container(
            decoration: AppDecorations.containerDecoration,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(s.recent_checkins, style: AppTextStyles.font16WhiteBold),
                vGap(10),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                  itemBuilder: (_, index) => ListTile(
                    title: Text('Workout ${index + 1}', style: const TextStyle(color: Colors.white70)),
                    trailing: Text('Date ${index + 1}', style: const TextStyle(color: Colors.white38)),
                  ),
                ),

              ],
            ),
          ),

          vGap(10),
          Text(s.private_notes, style: AppTextStyles.font16WhiteBold,),
          vGap(5),
          CustomTextFormField(textInputType: TextInputType.text, maxLines: 3,),
          vGap(10),
          CustomButton(
            color: AppColors.secondary,
            width: 100.w,
            text: s.save_notes, onPressed: () {

          },)

        ],
      ),
    );
  }

  Widget buildContainer({
    required String title,
    required String subtitle,
    required String duration,
  }) {
    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center, color: Colors.grey),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('Edit', style: TextStyle(color: Colors.white70)),
            ),
            title: Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(duration, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
