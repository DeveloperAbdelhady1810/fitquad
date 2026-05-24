import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ColumnChartWidget extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final double minY;
  final double maxY;
  final Map<int, String>? bottomTitles;

  const ColumnChartWidget({
    super.key,
    required this.barGroups,
    required this.minY,
    required this.maxY,
    this.bottomTitles,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          minY: minY,
          maxY: maxY,

          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (bottomTitles != null &&
                      bottomTitles!.containsKey(index)) {
                    return Text(
                      bottomTitles![index]!,
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          barGroups: barGroups,
        ),
      ),
    );
  }
}