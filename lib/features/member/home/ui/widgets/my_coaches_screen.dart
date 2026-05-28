import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'package:gym_app/features/member/home/ui/widgets/member_chat_screen.dart';

class MyCoachesScreen extends StatefulWidget {
  static const routeName = '/my-coaches';

  const MyCoachesScreen({super.key});

  @override
  State<MyCoachesScreen> createState() => _MyCoachesScreenState();
}

class _MyCoachesScreenState extends State<MyCoachesScreen> {
  List<Map<String, dynamic>> _coaches = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await MemberRepository.getMyCoaches();
      setState(() {
        _coaches = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: IconThemeData(color: AppColors.grey),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Coaches', style: AppTextStyles.font16WhiteBold),
            Text(
              'Your enrolled coaching team',
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : _error != null
              ? _ErrorState(error: _error!, onRetry: _load)
              : _coaches.isEmpty
                  ? _LockedState(context: context)
                  : _CoachList(coaches: _coaches),
    );
  }
}

// ── Locked state (no coach) ───────────────────────────────────────────────────

class _LockedState extends StatelessWidget {
  final BuildContext context;
  const _LockedState({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          vGap(40),
          // Lock icon
          Container(
            width: 96.r,
            height: 96.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(Icons.lock_outline_rounded,
                color: AppColors.grey, size: 44.r),
          ),
          vGap(24),
          Text('No Coach Yet',
              style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 20.sp)),
          vGap(10),
          Text(
            'Hire a personal coach to unlock direct messaging.\nYour coach will guide you, track your progress, and answer your questions.',
            style: AppTextStyles.font14GreyRegular.copyWith(height: 1.6),
            textAlign: TextAlign.center,
          ),
          vGap(32),

          // AI coach card (always available)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16.r),
              border:
                  Border.all(color: AppColors.teal.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome,
                      color: AppColors.teal, size: 24.r),
                ),
                hGap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Coach — Always Available',
                          style: AppTextStyles.font14WhiteRegular
                              .copyWith(fontWeight: FontWeight.w600)),
                      vGap(3),
                      Text(
                        'Ask nutrition, workout, or recovery questions anytime.',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          vGap(10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ctx.pop(),
              icon: Icon(Icons.auto_awesome,
                  color: AppColors.teal, size: 16.r),
              label: Text('Open AI Coach',
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(color: AppColors.teal)),
              style: OutlinedButton.styleFrom(
                side:
                    BorderSide(color: AppColors.teal.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 13.h),
              ),
            ),
          ),
          vGap(12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => ctx.push('/choose_coach'),
              icon: Icon(Icons.sports_gymnastics, size: 18.r),
              label: const Text('Find a Coach'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                textStyle: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coach list ────────────────────────────────────────────────────────────────

class _CoachList extends StatelessWidget {
  final List<Map<String, dynamic>> coaches;
  const _CoachList({required this.coaches});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: coaches.length,
      separatorBuilder: (_, __) => vGap(12),
      itemBuilder: (_, i) => _CoachCard(data: coaches[i]),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _CoachCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? 'Coach';
    final specialization = data['specialization'] as String? ?? '';
    final coachType = data['coach_type'] as String? ?? '';
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final planType = data['plan_type'] as String? ?? '';
    final status = data['status'] as String? ?? '';

    final initials = _initials(name);
    final typeLabel = _typeLabel(coachType);
    final typeColor = _typeColor(coachType);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                  child: Text(initials,
                      style: AppTextStyles.font16WhiteBold
                          .copyWith(color: AppColors.teal, fontSize: 17.sp)),
                ),
                hGap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.font16WhiteBold),
                      vGap(2),
                      Text(specialization,
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(color: AppColors.emerald, fontSize: 12.sp)),
                      vGap(6),
                      Row(
                        children: [
                          _Chip(label: typeLabel, color: typeColor),
                          hGap(6),
                          _Chip(
                              label: _planLabel(planType),
                              color: AppColors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            color: AppColors.emerald, size: 14.r),
                        hGap(3),
                        Text(rating.toStringAsFixed(1),
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp)),
                      ],
                    ),
                    vGap(6),
                    _StatusBadge(status: status),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // ── Actions ───────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemberChatScreen(coachName: name),
                      ),
                    ),
                    icon: Icon(Icons.chat_bubble_outline, size: 16.r),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                      textStyle: AppTextStyles.font14WhiteRegular
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _typeLabel(String type) => switch (type) {
        'training' => 'Training',
        'nutrition' => 'Nutrition',
        'both' => 'Training + Nutrition',
        _ => 'Coach',
      };

  Color _typeColor(String type) => switch (type) {
        'training' => AppColors.blue,
        'nutrition' => AppColors.emerald,
        'both' => AppColors.purple,
        _ => AppColors.grey,
      };

  String _planLabel(String type) => switch (type) {
        'workout' => 'Workout Plan',
        'nutrition' => 'Nutrition Plan',
        'both' => 'Full Plan',
        _ => 'Plan',
      };
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label,
          style: AppTextStyles.font14GreyRegular.copyWith(
              color: color, fontSize: 10.sp, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isActive = status == 'accepted';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.emerald : AppColors.grey)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
            color: (isActive ? AppColors.emerald : AppColors.grey)
                .withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5.r,
            height: 5.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.emerald : AppColors.grey,
            ),
          ),
          hGap(4),
          Text(isActive ? 'Active' : 'Completed',
              style: AppTextStyles.font14GreyRegular.copyWith(
                  color: isActive ? AppColors.emerald : AppColors.grey,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.red, size: 48.r),
          vGap(12),
          Text('Could not load coaches',
              style: AppTextStyles.font16WhiteBold),
          vGap(8),
          Text(error,
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center),
          vGap(16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
