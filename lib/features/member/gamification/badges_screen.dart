import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/member/community/leaderboard_screen.dart';

import '../../../core/helpers/app_decoration.dart';
import '../../../core/helpers/spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/repositories/member_repository.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});
  static const String routeName = '/badges';

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<dynamic> _badges = [];
  Map<String, dynamic>? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await MemberRepository.getProgress();
      if (mounted) {
        setState(() {
          _progress = data;
          _badges = (data['badges'] as List?) ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final earned  = _badges.where((b) => b['earned'] == true).length;
    final total   = _badges.length;
    final streak  = (_progress?['streak_days'] as num?)?.toInt() ?? 0;
    final xp      = (_progress?['xp_points'] as num?)?.toInt() ?? 0;
    final level   = (_progress?['level'] as num?)?.toInt() ?? 1;
    final checkins= (_progress?['total_checkins'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Achievements', style: AppTextStyles.font16WhiteBold),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_outlined, color: AppColors.teal),
            tooltip: 'Leaderboard',
            onPressed: () => context.push(LeaderboardScreen.routeName),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatCard(label: 'Level', value: '$level', icon: '⭐', color: AppColors.teal),
                      hGap(10),
                      _StatCard(label: 'Streak', value: '$streak d', icon: '🔥', color: Colors.orange),
                      hGap(10),
                      _StatCard(label: 'XP', value: '$xp', icon: '🌟', color: AppColors.emerald),
                      hGap(10),
                      _StatCard(label: 'Check-ins', value: '$checkins', icon: '📍', color: AppColors.blue),
                    ],
                  ),
                  vGap(20),

                  // Badge progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Badges', style: AppTextStyles.font16WhiteBold),
                      Text(
                        '$earned / $total earned',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(color: AppColors.teal),
                      ),
                    ],
                  ),
                  vGap(4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: total > 0 ? earned / total : 0,
                      backgroundColor: Colors.white12,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.teal),
                      minHeight: 8,
                    ),
                  ),
                  vGap(20),

                  // Badge grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _badges.length,
                    itemBuilder: (context, i) {
                      final badge = _badges[i] as Map<String, dynamic>;
                      final isEarned = badge['earned'] == true;
                      final current  = (badge['current_value'] as num?)?.toInt() ?? 0;
                      final required = (badge['requirement_value'] as num?)?.toInt() ?? 1;

                      return _BadgeTile(
                        icon: badge['icon'] as String? ?? '🏅',
                        name: badge['name'] as String? ?? '',
                        description: badge['description'] as String? ?? '',
                        isEarned: isEarned,
                        currentValue: current,
                        requiredValue: required,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: AppDecorations.containerDecoration.copyWith(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 20.sp)),
            vGap(4),
            Text(
              value,
              style: AppTextStyles.font16WhiteBold.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final bool isEarned;
  final int currentValue;
  final int requiredValue;

  const _BadgeTile({
    required this.icon,
    required this.name,
    required this.description,
    required this.isEarned,
    required this.currentValue,
    required this.requiredValue,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: AnimatedOpacity(
        opacity: isEarned ? 1.0 : 0.35,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            color: isEarned
                ? AppColors.teal.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isEarned
                  ? AppColors.teal.withValues(alpha: 0.4)
                  : Colors.white12,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: TextStyle(fontSize: 34.sp)),
              vGap(6),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  name,
                  style: AppTextStyles.font14GreyRegular.copyWith(
                    color: isEarned ? Colors.white : AppColors.grey,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isEarned && requiredValue > 0) ...[
                vGap(4),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2.r),
                    child: LinearProgressIndicator(
                      value: (currentValue / requiredValue).clamp(0.0, 1.0),
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.grey),
                      minHeight: 3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: TextStyle(fontSize: 56.sp)),
            vGap(12),
            Text(name, style: AppTextStyles.font16WhiteBold),
            vGap(8),
            Text(
              description,
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center,
            ),
            if (!isEarned) ...[
              vGap(16),
              Text(
                'Progress: $currentValue / $requiredValue',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.teal),
              ),
              vGap(8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: (currentValue / requiredValue).clamp(0.0, 1.0),
                  backgroundColor: Colors.white12,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.teal),
                  minHeight: 8,
                ),
              ),
            ] else ...[
              vGap(12),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '✅ Earned!',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(color: AppColors.emerald),
                ),
              ),
            ],
            vGap(20),
          ],
        ),
      ),
    );
  }
}
