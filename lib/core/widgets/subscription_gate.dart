import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/member/data/models/member_model.dart';
import '../../features/member/home/manager/member_cubit.dart';
import '../../features/member/home/manager/member_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../helpers/spacing.dart';

/// Wraps a premium feature. If the member's subscription is not active,
/// tapping it shows an upgrade prompt instead.
class SubscriptionGate extends StatelessWidget {
  final Widget child;
  final String featureName;
  final String featureDescription;

  const SubscriptionGate({
    super.key,
    required this.child,
    this.featureName = 'Premium Feature',
    this.featureDescription =
        'Upgrade your membership to access this feature.',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final isActive = state is MemberLoaded &&
            state.member.status == MemberStatus.active;
        if (isActive) return child;

        return GestureDetector(
          onTap: () => _showUpgradeSheet(context),
          child: Stack(
            children: [
              IgnorePointer(child: Opacity(opacity: 0.4, child: child)),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline,
                            color: Colors.white, size: 14.r),
                        hGap(4),
                        Text('Upgrade',
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(color: Colors.white, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.all(28.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium_outlined,
                color: AppColors.teal, size: 52.r),
            vGap(16),
            Text(featureName,
                style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 18.sp),
                textAlign: TextAlign.center),
            vGap(8),
            Text(featureDescription,
                style: AppTextStyles.font14GreyRegular.copyWith(height: 1.4),
                textAlign: TextAlign.center),
            vGap(24),
            _PlanComparison(),
            vGap(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('View Plans',
                    style: AppTextStyles.font16WhiteBold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanComparison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      ('AI Coach Chat', false, true),
      ('Personal Coach', false, true),
      ('Nutrition Plans', true, true),
      ('Workout Plans', true, true),
      ('InBody Tracking', true, true),
      ('Gamification & Streaks', true, true),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                _ColHeader('Basic'),
                hGap(16),
                _ColHeader('Pro', highlight: true),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          ...features.map((f) => _FeatureRow(
                name: f.$1,
                inBasic: f.$2,
                inPro: f.$3,
              )),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;
  final bool highlight;

  const _ColHeader(this.label, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      child: Text(
        label,
        style: AppTextStyles.font14GreyRegular.copyWith(
          color: highlight ? AppColors.teal : AppColors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String name;
  final bool inBasic;
  final bool inPro;

  const _FeatureRow({
    required this.name,
    required this.inBasic,
    required this.inPro,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(name,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 12.sp)),
          ),
          SizedBox(
            width: 50.w,
            child: Icon(
              inBasic ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: inBasic ? AppColors.emerald : Colors.red.withValues(alpha: 0.6),
              size: 18.r,
            ),
          ),
          hGap(16),
          SizedBox(
            width: 50.w,
            child: Icon(
              inPro ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: inPro ? AppColors.teal : Colors.red.withValues(alpha: 0.6),
              size: 18.r,
            ),
          ),
        ],
      ),
    );
  }
}
