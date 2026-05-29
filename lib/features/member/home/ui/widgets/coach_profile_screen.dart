import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/widgets/app_avatar.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/data/models/coach_model.dart';
import 'package:gym_app/features/member/payment/data/payment_repository.dart';
import 'package:gym_app/features/member/payment/ui/payment_webview_screen.dart';

class CoachProfileScreen extends StatelessWidget {
  final CoachModel coach;
  const CoachProfileScreen({super.key, required this.coach});

  static const routeName = '/coach-profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          _HeroSliver(coach: coach),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SpecializationChips(coach: coach),
                  vGap(20),
                  _StatsRow(coach: coach),
                  vGap(20),
                  if (coach.bio.isNotEmpty) ...[
                    Text('About', style: AppTextStyles.font16WhiteBold),
                    vGap(10),
                    Text(
                      coach.bio,
                      style: AppTextStyles.font14GreyRegular.copyWith(
                          height: 1.6),
                    ),
                    vGap(20),
                  ],
                  Text('What you get', style: AppTextStyles.font16WhiteBold),
                  vGap(12),
                  _BenefitItem(
                      icon: Icons.fitness_center,
                      color: AppColors.teal,
                      label: coach.service),
                  vGap(8),
                  _BenefitItem(
                      icon: Icons.timer_outlined,
                      color: AppColors.blue,
                      label: 'Plan delivered in ${coach.turnaround}'),
                  vGap(8),
                  _BenefitItem(
                      icon: Icons.message_outlined,
                      color: AppColors.purple,
                      label: 'Direct messaging with your coach'),
                  vGap(8),
                  _BenefitItem(
                      icon: Icons.track_changes,
                      color: AppColors.emerald,
                      label: 'Progress tracking & plan adjustments'),
                  vGap(32),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _HireBar(coach: coach),
    );
  }
}

// ── Hero Sliver ───────────────────────────────────────────────────────────────

class _HeroSliver extends StatelessWidget {
  final CoachModel coach;
  const _HeroSliver({required this.coach});


  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260.h,
      pinned: true,
      backgroundColor: AppColors.secondary,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.teal.withValues(alpha: 0.3),
                AppColors.secondary,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              AppAvatar(name: coach.name, url: coach.avatarUrl, radius: 52),
              vGap(12),
              Text(coach.name, style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 20.sp)),
              vGap(4),
              Text(
                coach.jobTitle,
                style: AppTextStyles.font14GreyRegular.copyWith(
                    color: AppColors.emerald),
              ),
              vGap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < coach.rating.round();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: filled ? Colors.amber : AppColors.grey,
                    size: 18.r,
                  );
                }),
              ),
              vGap(4),
              Text(
                '${coach.rating.toStringAsFixed(1)} · ${coach.reviewsCount} reviews',
                style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Specialization Chips ──────────────────────────────────────────────────────

class _SpecializationChips extends StatelessWidget {
  final CoachModel coach;
  const _SpecializationChips({required this.coach});

  @override
  Widget build(BuildContext context) {
    final chips = <_ChipData>[];
    if (coach.coachType == 'training' || coach.coachType == 'both') {
      chips.add(_ChipData('Personal Training', Icons.fitness_center, AppColors.teal));
    }
    if (coach.coachType == 'nutrition' || coach.coachType == 'both') {
      chips.add(_ChipData('Nutrition Coaching', Icons.restaurant_menu, AppColors.emerald));
    }
    if (chips.isEmpty) {
      chips.add(_ChipData(coach.service, Icons.sports_gymnastics, AppColors.blue));
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: chips.map((c) => _Chip(data: c)).toList(),
    );
  }
}

class _ChipData {
  final String label;
  final IconData icon;
  final Color color;
  const _ChipData(this.label, this.icon, this.color);
}

class _Chip extends StatelessWidget {
  final _ChipData data;
  const _Chip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: data.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, color: data.color, size: 14.r),
          SizedBox(width: 6.w),
          Text(
            data.label,
            style: AppTextStyles.font14GreyRegular.copyWith(
                color: data.color, fontSize: 12.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final CoachModel coach;
  const _StatsRow({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          label: 'Price',
          value: '${coach.price.toStringAsFixed(0)} EGP',
          icon: Icons.payments_outlined,
          color: AppColors.teal,
        ),
        hGap(10),
        _StatTile(
          label: 'Delivery',
          value: coach.turnaround,
          icon: Icons.timer_outlined,
          color: AppColors.blue,
        ),
        hGap(10),
        _StatTile(
          label: 'Rating',
          value: coach.rating.toStringAsFixed(1),
          icon: Icons.star_rounded,
          color: Colors.amber,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: AppDecorations.containerDecoration.copyWith(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.r),
            vGap(6),
            Text(value,
                style: AppTextStyles.font14WhiteRegular.copyWith(
                    fontWeight: FontWeight.bold, color: color, fontSize: 12.sp),
                textAlign: TextAlign.center),
            vGap(2),
            Text(label,
                style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Benefit Item ─────────────────────────────────────────────────────────────

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _BenefitItem(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16.r),
        ),
        hGap(12),
        Expanded(
          child: Text(label,
              style: AppTextStyles.font14GreyRegular.copyWith(height: 1.4)),
        ),
      ],
    );
  }
}

// ── Hire Bottom Bar ───────────────────────────────────────────────────────────

class _HireBar extends StatefulWidget {
  final CoachModel coach;
  const _HireBar({required this.coach});

  @override
  State<_HireBar> createState() => _HireBarState();
}

class _HireBarState extends State<_HireBar> {
  bool _loading = false;


  Future<void> _hire() async {
    setState(() => _loading = true);
    try {
      final result = await PaymentRepository.initiateCoachPayment(
          coachId: widget.coach.id);
      if (!mounted) return;
      context.push(PaymentWebviewScreen.routeName, extra: {
        'payment_url': result['payment_url'] as String,
        'coach_name':
            result['coach_name'] as String? ?? widget.coach.name,
        'total_amount': result['total_amount'],
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Payment failed: ${e.toString()}'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showHireOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final coach = widget.coach;
        final platformFee = coach.price * 0.05;
        const processingFee = 5.0;
        final total = coach.price + platformFee + processingFee;

        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(name: coach.name, url: coach.avatarUrl, radius: 22),
                  hGap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(coach.name, style: AppTextStyles.font16WhiteBold),
                        Text(coach.jobTitle,
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(color: AppColors.emerald, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${total.toStringAsFixed(0)} EGP',
                      style: AppTextStyles.font16WhiteBold.copyWith(
                          color: AppColors.teal, fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
              vGap(16),
              Container(
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    _FeeLineItem(label: 'Coach fee', value: '${coach.price.toStringAsFixed(0)} EGP'),
                    vGap(6),
                    _FeeLineItem(
                        label: 'Platform fee (5%)',
                        value: '${platformFee.toStringAsFixed(0)} EGP',
                        muted: true),
                    vGap(6),
                    _FeeLineItem(
                        label: 'Processing fee',
                        value: '5 EGP',
                        muted: true),
                    Divider(color: Colors.white12, height: 20.h),
                    _FeeLineItem(
                        label: 'Total',
                        value: '${total.toStringAsFixed(0)} EGP',
                        bold: true,
                        color: AppColors.teal),
                  ],
                ),
              ),
              vGap(20),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _hire();
                  },
                  icon: Icon(Icons.lock_outlined, size: 18.r),
                  label: const Text('Confirm & Pay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    textStyle: AppTextStyles.font16WhiteBold.copyWith(fontSize: 15.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final coach = widget.coach;
    final total = coach.price * 1.05 + 5;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          border: Border(top: BorderSide(color: Colors.white12)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session fee',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 11.sp)),
                Text(
                  '${total.toStringAsFixed(0)} EGP',
                  style: AppTextStyles.font16WhiteBold
                      .copyWith(color: AppColors.teal, fontSize: 22.sp),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _showHireOptions,
                icon: _loading
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.sports_gymnastics, size: 18.r),
                label: Text(_loading ? 'Processing…' : 'Hire Coach'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r)),
                  textStyle: AppTextStyles.font16WhiteBold.copyWith(fontSize: 15.sp),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeLineItem extends StatelessWidget {
  final String label;
  final String value;
  final bool muted;
  final bool bold;
  final Color? color;

  const _FeeLineItem({
    required this.label,
    required this.value,
    this.muted = false,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? AppTextStyles.font16WhiteBold.copyWith(
            color: color ?? Colors.white, fontSize: 14.sp)
        : AppTextStyles.font14GreyRegular.copyWith(
            color: muted ? AppColors.grey : Colors.white70);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
