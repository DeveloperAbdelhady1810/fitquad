import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/data/models/coach_model.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/home/ui/widgets/coach_profile_screen.dart';
import 'package:gym_app/features/member/payment/data/payment_repository.dart';
import 'package:gym_app/features/member/payment/ui/payment_webview_screen.dart';

import '../../../../../generated/l10n.dart';

class ChooseCoachScreen extends StatelessWidget {
  const ChooseCoachScreen({super.key});
  static const String routeName = '/choose_coach';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.grey),
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.find_a_coach, style: AppTextStyles.font16WhiteBold),
            Text(
              s.select_a_pro_to_build_workout,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
            ),
          ],
        ),
      ),
      body: BlocBuilder<MemberCubit, MemberState>(
        builder: (context, state) {
          if (state is MemberLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.teal));
          }
          if (state is MemberError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: AppColors.red, size: 48.r),
                  vGap(12),
                  Text(state.message, style: AppTextStyles.font16GreyRegular),
                ],
              ),
            );
          }
          if (state is CoachLoaded) {
            if (state.coaches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_gymnastics,
                        color: AppColors.grey, size: 56.r),
                    vGap(16),
                    Text('No coaches available',
                        style: AppTextStyles.font16WhiteBold),
                    vGap(8),
                    Text('Check back later or try a different category.',
                        style: AppTextStyles.font14GreyRegular,
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: state.coaches.length,
              separatorBuilder: (_, __) => vGap(14),
              itemBuilder: (context, index) {
                return _CoachCard(coach: state.coaches[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Coach Card ───────────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  final CoachModel coach;
  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Capture scaffold context here — before any dialog opens
    final scaffoldCtx = context;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CoachProfileScreen(coach: coach)),
      ),
      child: Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                  child: Text(
                    _initials(coach.name),
                    style: AppTextStyles.font16WhiteBold.copyWith(
                        color: AppColors.teal, fontSize: 18.sp),
                  ),
                ),
                hGap(12),
                // Name + title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(coach.name, style: AppTextStyles.font16WhiteBold),
                      vGap(2),
                      Text(
                        coach.jobTitle,
                        style: AppTextStyles.font14GreyRegular.copyWith(
                            color: AppColors.emerald),
                      ),
                      vGap(6),
                      Row(
                        children: [
                          _Tag(
                            label: coach.service,
                            color: AppColors.blue,
                          ),
                          hGap(6),
                          _Tag(
                            label: coach.turnaround,
                            color: AppColors.purple,
                            icon: Icons.timer_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                            color: AppColors.emerald.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.emerald, size: 14.r),
                          hGap(4),
                          Text(
                            coach.rating.toStringAsFixed(1),
                            style: AppTextStyles.font14GreyRegular.copyWith(
                                color: AppColors.emerald,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                    vGap(4),
                    Text(
                      '${coach.reviewsCount} reviews',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(fontSize: 10.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Bio ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Text(
              coach.bio,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Divider(height: 1),

          // ── Price + Hire / Subscribed ────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.price.toUpperCase(),
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 10.sp)),
                    vGap(2),
                    Text(
                      '${coach.price.toStringAsFixed(0)} EGP',
                      style: AppTextStyles.font16WhiteBold.copyWith(
                          color: AppColors.teal, fontSize: 18.sp),
                    ),
                  ],
                ),
                const Spacer(),
                coach.isSubscribed
                    ? Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                              color: AppColors.emerald.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: AppColors.emerald, size: 16.r),
                            hGap(6),
                            Text('Subscribed',
                                style: AppTextStyles.font14GreyRegular.copyWith(
                                    color: AppColors.emerald,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 44.h,
                        child: ElevatedButton.icon(
                          onPressed: () => _showHireDialog(scaffoldCtx, coach),
                          icon: Icon(Icons.sports_gymnastics, size: 16.r),
                          label: Text(s.hire_coach),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
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
      ),
    );
  }

  void _showHireDialog(BuildContext scaffoldCtx, CoachModel coach) {
    final s = S.of(scaffoldCtx);
    final platformFee = (coach.price * 0.05);
    const processingFee = 5.0;
    final total = coach.price + platformFee + processingFee;

    showDialog(
      context: scaffoldCtx,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 40.h),
        child: Container(
          decoration: AppDecorations.containerDecoration.copyWith(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dialog header ──────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 12.w, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.sports_gymnastics,
                          color: AppColors.teal, size: 22.r),
                    ),
                    hGap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.confirm_request,
                              style: AppTextStyles.font16WhiteBold),
                          vGap(2),
                          Text(
                            '${s.you_are_about_to_hire_coach} ${coach.name}',
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(scaffoldCtx),
                      icon:
                          Icon(Icons.close, color: AppColors.grey, size: 20.r),
                    ),
                  ],
                ),
              ),

              // ── Coach quick info ───────────────────────────────
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor:
                            AppColors.teal.withValues(alpha: 0.15),
                        child: Text(_initials(coach.name),
                            style: AppTextStyles.font14WhiteRegular
                                .copyWith(color: AppColors.teal)),
                      ),
                      hGap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coach.name,
                                style: AppTextStyles.font14WhiteRegular
                                    .copyWith(fontWeight: FontWeight.w600)),
                            Text(coach.jobTitle,
                                style: AppTextStyles.font14GreyRegular
                                    .copyWith(
                                        fontSize: 11.sp,
                                        color: AppColors.emerald)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: AppColors.emerald, size: 13.r),
                          hGap(3),
                          Text(coach.rating.toStringAsFixed(1),
                              style: AppTextStyles.font14GreyRegular
                                  .copyWith(color: AppColors.emerald)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Fee breakdown ──────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      _FeeRow(
                        icon: Icons.fitness_center,
                        label: s.service,
                        value: coach.service,
                        iconColor: AppColors.teal,
                      ),
                      _FeeRow(
                        icon: Icons.timer_outlined,
                        label: s.turnaround,
                        value: coach.turnaround,
                        iconColor: AppColors.blue,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      _FeeRow(
                        icon: Icons.percent,
                        label: 'Platform fee (5%)',
                        value:
                            '${platformFee.toStringAsFixed(0)} EGP',
                        iconColor: AppColors.grey,
                        valueStyle: AppTextStyles.font14GreyRegular,
                      ),
                      _FeeRow(
                        icon: Icons.credit_card_outlined,
                        label: 'Processing fee',
                        value: '5 EGP',
                        iconColor: AppColors.grey,
                        valueStyle: AppTextStyles.font14GreyRegular,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      _FeeRow(
                        icon: Icons.receipt_outlined,
                        label: s.total,
                        value: '${total.toStringAsFixed(0)} EGP',
                        iconColor: AppColors.emerald,
                        valueStyle: AppTextStyles.font16WhiteBold
                            .copyWith(color: AppColors.emerald),
                      ),
                    ],
                  ),
                ),
              ),

              vGap(16),

              // ── Action buttons ─────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(scaffoldCtx),
                        style: OutlinedButton.styleFrom(
                          side:
                              BorderSide(color: AppColors.grey.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: Text(s.cancel,
                            style: AppTextStyles.font14GreyRegular),
                      ),
                    ),
                    hGap(10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            _initiatePayment(scaffoldCtx, coach),
                        icon: Icon(Icons.lock_outlined, size: 16.r),
                        label: Text(s.confirm_and_pay),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
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
        ),
      ),
    );
  }

  Future<void> _initiatePayment(
      BuildContext scaffoldCtx, CoachModel coach) async {
    // Close the confirm dialog using the scaffold context (still mounted)
    Navigator.of(scaffoldCtx).pop();

    // Show loading indicator
    if (!scaffoldCtx.mounted) return;
    ScaffoldMessenger.of(scaffoldCtx).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Preparing payment…'),
          ],
        ),
        duration: Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
      ),
    );

    try {
      final result =
          await PaymentRepository.initiateCoachPayment(coachId: coach.id);
      if (!scaffoldCtx.mounted) return;
      ScaffoldMessenger.of(scaffoldCtx).hideCurrentSnackBar();
      scaffoldCtx.push(PaymentWebviewScreen.routeName, extra: {
        'payment_url': result['payment_url'] as String,
        'coach_name': result['coach_name'] as String? ?? coach.name,
        'total_amount': result['total_amount'],
      });
    } catch (e) {
      if (!scaffoldCtx.mounted) return;
      ScaffoldMessenger.of(scaffoldCtx).hideCurrentSnackBar();
      ScaffoldMessenger.of(scaffoldCtx).showSnackBar(SnackBar(
        content: Text('Payment failed: ${e.toString()}'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

// ── Helper Widgets ────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Tag({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 10.r),
            SizedBox(width: 3.w),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.font14GreyRegular.copyWith(
                  color: color,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final TextStyle? valueStyle;

  const _FeeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16.r),
          hGap(10),
          Expanded(
            child: Text(label, style: AppTextStyles.font14GreyRegular),
          ),
          Text(
            value,
            style: valueStyle ?? AppTextStyles.font14WhiteRegular,
          ),
        ],
      ),
    );
  }
}
