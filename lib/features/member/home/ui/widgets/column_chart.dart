import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class WeeklyColumnChart extends StatelessWidget {
  const WeeklyColumnChart({
    super.key,
    required this.values,
    this.maxY = 100,
    this.barColor = Colors.green,
  });

  final List<double> values;

  final double maxY;

  final Color barColor;

  static const List<String> _days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];


  @override
  Widget build(BuildContext context) {

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _days[index],
                    style:AppTextStyles.font16GreyBold
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          values.length,
              (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: values[index],
                width: 14,
                borderRadius: BorderRadius.circular(6),
                color: barColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
