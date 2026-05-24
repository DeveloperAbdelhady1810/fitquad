import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';
import 'package:gym_app/features/admin/ui/widgets/pie_chart.dart';

import '../../../member/home/ui/widgets/line_chart.dart';

class AnalyticsBody extends StatefulWidget {
  const AnalyticsBody({super.key});

  @override
  State<AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<AnalyticsBody> {
  Map<String, dynamic> _data = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getAnalytics();
      if (mounted) setState(() { _data = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<FlSpot> _revenueSpots() {
    final revenue = _data['monthly_revenue'] as List<dynamic>?;
    if (revenue == null || revenue.isEmpty) {
      return const [FlSpot(1, 2), FlSpot(2, 4), FlSpot(3, 3), FlSpot(4, 5)];
    }
    return revenue.asMap().entries.map((e) {
      final val = (e.value as num?)?.toDouble() ?? 0;
      return FlSpot((e.key + 1).toDouble(), val);
    }).toList();
  }

  Map<double, String> _revenueBottomTitles() {
    final months = _data['months'] as List<dynamic>?;
    if (months == null || months.isEmpty) {
      return {1: 'Sat', 2: 'Sun', 3: 'Mon', 4: 'Tue'};
    }
    return {
      for (var i = 0; i < months.length; i++)
        (i + 1).toDouble(): months[i].toString()
    };
  }

  List<PieChartSectionData> _pieSections() {
    final membership = _data['membership_distribution'] as Map<String, dynamic>?;
    if (membership == null || membership.isEmpty) {
      return [
        PieChartSectionData(value: 82, color: Colors.green, title: 'Active', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        PieChartSectionData(value: 40, color: Colors.purple, title: 'Pro', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        PieChartSectionData(value: 30, color: Colors.grey, title: 'Basic', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        PieChartSectionData(value: 20, color: Colors.blue, title: 'VIP', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ];
    }
    final colors = [Colors.green, Colors.purple, Colors.grey, Colors.blue, Colors.orange];
    int i = 0;
    return membership.entries.map((e) {
      final color = colors[i++ % colors.length];
      return PieChartSectionData(
        value: (e.value as num?)?.toDouble() ?? 0,
        color: color,
        title: e.key,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final spots = _revenueSpots();
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: AppDecorations.containerDecoration,
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Revenue Trend', style: AppTextStyles.font16WhiteBold),
                ),
                LineChartWidget(
                  spots: spots,
                  minX: 1,
                  maxX: spots.length.toDouble(),
                  minY: 0,
                  maxY: maxY > 0 ? maxY : 10,
                  bottomTitles: _revenueBottomTitles(),
                ),
              ],
            ),
          ),
          vGap(10),
          Container(
            decoration: AppDecorations.containerDecoration,
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Membership Distribution', style: AppTextStyles.font16WhiteBold),
                ),
                PieChartWidget(sections: _pieSections()),
              ],
            ),
          ),
          if (_data['kpis'] != null) ...[
            vGap(10),
            _KpiGrid(kpis: _data['kpis'] as Map<String, dynamic>),
          ],
        ],
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  final Map<String, dynamic> kpis;
  const _KpiGrid({required this.kpis});

  @override
  Widget build(BuildContext context) {
    final entries = kpis.entries.toList();
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: AppDecorations.containerDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Key Metrics', style: AppTextStyles.font16WhiteBold),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: entries.length,
            itemBuilder: (_, i) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${entries[i].value}',
                      style: AppTextStyles.font16WhiteBold,
                    ),
                    Text(
                      entries[i].key.replaceAll('_', ' '),
                      style: AppTextStyles.font14GreyRegular,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
