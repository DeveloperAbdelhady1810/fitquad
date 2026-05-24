import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/admin/data/admin_repository.dart';

import '../../../../core/widgets/column_chart.dart';
import '../../../../generated/l10n.dart';
import '../../../member/home/ui/widgets/line_chart.dart';

class AdminViewBody extends StatefulWidget {
  const AdminViewBody({super.key});

  @override
  State<AdminViewBody> createState() => _AdminViewBodyState();
}

class _AdminViewBodyState extends State<AdminViewBody> {
  Map<String, dynamic> _dashboard = {};
  List<dynamic> _topProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        AdminRepository.getDashboard(),
        AdminRepository.getProducts(),
      ]);
      if (mounted) {
        setState(() {
          _dashboard = results[0] as Map<String, dynamic>;
          _topProducts = (results[1] as List<dynamic>).take(3).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<_StatData> get _stats {
    return [
      _StatData(
        label: 'Total Members',
        value: '${_dashboard['total_members'] ?? '-'}',
        sub: '+${_dashboard['new_members_this_week'] ?? 0} this week',
        color: Colors.purple,
      ),
      _StatData(
        label: 'Active Subs',
        value: '${_dashboard['active_subscriptions'] ?? '-'}',
        sub: '',
        color: Colors.blue,
      ),
      _StatData(
        label: 'Revenue',
        value: '\$${_dashboard['monthly_revenue'] ?? '-'}',
        sub: 'This month',
        color: Colors.green,
      ),
      _StatData(
        label: 'Check-Ins',
        value: '${_dashboard['check_ins_today'] ?? '-'}',
        sub: 'Today',
        color: Colors.orange,
      ),
      _StatData(
        label: 'Coaches',
        value: '${_dashboard['total_coaches'] ?? '-'}',
        sub: '',
        color: Colors.teal,
      ),
      _StatData(
        label: 'Orders',
        value: '${_dashboard['pending_orders'] ?? '-'}',
        sub: 'Pending',
        color: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Stats cards
          SizedBox(
            height: 110,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _stats.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _StatCard(data: _stats[i]),
                  ),
          ),

          const SizedBox(height: 16),

          /// Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.actions, style: AppTextStyles.font16WhiteBold),
                vGap(10),
                const _QuickActionsGrid(),
              ],
            ),
          ),
          vGap(10),
          Container(
            decoration: AppDecorations.containerDecoration,
            margin: const EdgeInsets.all(10),
            child: LineChartWidget(
              spots: const [
                FlSpot(1, 2),
                FlSpot(2, 4),
                FlSpot(3, 3),
                FlSpot(4, 5),
              ],
              minX: 1,
              maxX: 4,
              minY: 0,
              maxY: 6,
              bottomTitles: {1: 'Sat', 2: 'Sun', 3: 'Mon', 4: 'Tue'},
            ),
          ),
          vGap(15),
          Container(
            decoration: AppDecorations.containerDecoration,
            margin: const EdgeInsets.all(10),
            child: ColumnChartWidget(
              minY: 0,
              maxY: 100,
              bottomTitles: {0: 'Sat', 1: 'Sun', 2: 'Mon', 3: 'Tue'},
              barGroups: [
                BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 40, width: 18, borderRadius: BorderRadius.circular(6))]),
                BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 70, width: 18, borderRadius: BorderRadius.circular(6))]),
              ],
            ),
          ),

          /// Top Products
          _Card(products: _topProducts),
        ],
      ),
    );
  }
}

class _StatData {
  final String label;
  final String value;
  final String sub;
  final Color color;
  const _StatData({required this.label, required this.value, required this.sub, required this.color});
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.value,
            style: AppTextStyles.font16WhiteBold.copyWith(color: data.color),
          ),
          vGap(5),
          Text(data.label, style: AppTextStyles.font14GreyRegular),
          if (data.sub.isNotEmpty) ...[
            vGap(5),
            Text(
              data.sub,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _QuickAction(title: s.add_staff, icon: Icons.person_add, color: Colors.blueAccent),
        _QuickAction(title: 'New Plan', icon: Icons.credit_card, color: Colors.purple),
        _QuickAction(title: 'Add Product', icon: Icons.indeterminate_check_box_outlined, color: AppColors.emerald),
        _QuickAction(title: 'Announce', icon: Icons.notifications_none, color: Colors.deepOrangeAccent),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _QuickAction({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: AppDecorations.containerDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35.sp, color: color),
            vGap(10),
            Text(title, style: AppTextStyles.font14GreyRegular),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<dynamic> products;
  const _Card({required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(10),
      decoration: AppDecorations.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Products', style: AppTextStyles.font16WhiteBold),
          vGap(10),
          if (products.isEmpty)
            const Center(child: Text('No products', style: TextStyle(color: Colors.white54)))
          else
            ...products.map((e) {
              final p = e as Map<String, dynamic>;
              final name = p['name'] as String? ?? '-';
              final sold = '${p['total_sold'] ?? p['stock_qty'] ?? 0} sold';
              return ListTile(
                title: Text(name, style: AppTextStyles.font14GreyRegular),
                trailing: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: AppDecorations.containerDecoration.copyWith(color: AppColors.primary),
                  child: Text(sold, style: AppTextStyles.font14WhiteRegular),
                ),
              );
            }),
        ],
      ),
    );
  }
}
