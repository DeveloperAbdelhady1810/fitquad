import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';

import '../../../../core/helpers/app_decoration.dart';
import '../../../../core/widgets/column_chart.dart';

class CheckInsBody extends StatefulWidget {
  const CheckInsBody({super.key});

  @override
  State<CheckInsBody> createState() => _CheckInsBodyState();
}

class _CheckInsBodyState extends State<CheckInsBody> {
  List<dynamic> _checkIns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await AdminRepository.getCheckIns();
      if (mounted) setState(() { _checkIns = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: AppDecorations.containerDecoration,
            margin: const EdgeInsets.all(10),
            child: ColumnChartWidget(
              minY: 0,
              maxY: 100,
              bottomTitles: {
                0: '6 AM',
                1: '8 AM',
                2: '10 AM',
                3: '12 PM',
                4: '2 PM',
                5: '4 PM',
                6: '6 PM',
                7: '8 PM',
              },
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 40, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 55, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 70, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 50, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 30, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 60, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 80, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 7, barRods: [BarChartRodData(toY: 45, width: 18, borderRadius: BorderRadius.circular(6))]),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: AppDecorations.containerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Today\'s Check-Ins', style: AppTextStyles.font16WhiteBold),
                vGap(10),
                Center(
                  child: Text(
                    '${_checkIns.length}',
                    style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 24.sp),
                  ),
                ),
                vGap(5),
                const Center(
                  child: Text(
                    'Members Checked In Today',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                vGap(10),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_checkIns.isEmpty)
                  const Center(
                    child: Text(
                      'No check-ins recorded',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                else
                  ..._checkIns.take(10).map((e) {
                    final c = e as Map<String, dynamic>;
                    final member = c['member'] as Map<String, dynamic>? ?? {};
                    final user = member['user'] as Map<String, dynamic>? ?? {};
                    final name = user['name'] as String? ?? 'Member';
                    final time = c['checked_in_at'] as String? ?? '';
                    final method = c['method'] as String? ?? 'manual';
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'M',
                          style: AppTextStyles.font14WhiteRegular,
                        ),
                      ),
                      title: Text(name, style: AppTextStyles.font14WhiteRegular),
                      subtitle: Text(
                        _formatTime(time),
                        style: AppTextStyles.font14GreyRegular,
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          method.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return iso;
    }
  }
}
