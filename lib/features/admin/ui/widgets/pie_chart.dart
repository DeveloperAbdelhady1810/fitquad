import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  final List<PieChartSectionData>? sections;
  const PieChartWidget({super.key, this.sections});

  @override
  Widget build(BuildContext context) {
    final data = sections ??
        [
          PieChartSectionData(value: 82, color: Colors.green, title: '82', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          PieChartSectionData(value: 82, color: Colors.purple, title: '82', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          PieChartSectionData(value: 82, color: Colors.grey, title: '82', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          PieChartSectionData(value: 65, color: Colors.blue, title: '65', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ];

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: data,
          sectionsSpace: 4,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }
}
