import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/helpers/app_decoration.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/repositories/member_repository.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  static const routeName = '/workout-history';

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<dynamic> _checkIns = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await MemberRepository.getCheckIns();
      if (mounted) setState(() { _checkIns = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Workout History', style: AppTextStyles.font16WhiteBold),
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : _checkIns.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: _checkIns.length,
                    separatorBuilder: (_, __) => vGap(12),
                    itemBuilder: (context, i) {
                      final ci = _checkIns[i] as Map<String, dynamic>;
                      return _CheckInCard(data: ci);
                    },
                  ),
                ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80.r, color: AppColors.grey),
          vGap(16),
          Text('No workouts yet', style: AppTextStyles.font16WhiteBold,
              textAlign: TextAlign.center),
          vGap(8),
          Text('Complete your first workout to see it here.',
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CheckInCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final checkedAt = data['checked_in_at'] as String? ??
        data['created_at'] as String? ?? '';
    final date = DateTime.tryParse(checkedAt);
    final dateStr = date != null
        ? DateFormat('EEEE, MMM d yyyy').format(date)
        : 'Unknown date';
    final timeStr = date != null ? DateFormat('h:mm a').format(date) : '';
    final branch = (data['branch'] as Map<String, dynamic>?)?['name'] as String?;
    final streakDays = (data['streak_days'] as num?)?.toInt();
    final xpGained = (data['xp_gained'] as num?)?.toInt();

    return Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          // Date column
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date != null ? DateFormat('d').format(date) : '--',
                  style: AppTextStyles.font16WhiteBold.copyWith(
                      color: AppColors.teal, fontSize: 18.sp),
                ),
                Text(
                  date != null ? DateFormat('MMM').format(date) : '',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 10.sp),
                ),
              ],
            ),
          ),
          hGap(14),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateStr,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                vGap(2),
                Text(timeStr.isNotEmpty ? 'Checked in at $timeStr' : 'Gym check-in',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 11.sp)),
                if (branch != null) ...[
                  vGap(2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12.r, color: AppColors.grey),
                      hGap(3),
                      Text(branch,
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // XP + streak badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (xpGained != null)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text('+$xpGained XP',
                      style: AppTextStyles.font14GreyRegular.copyWith(
                          color: AppColors.emerald,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold)),
                ),
              if (streakDays != null) ...[
                vGap(4),
                Text('🔥 $streakDays day streak',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 10.sp)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
