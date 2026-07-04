import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/data/models/coach_model.dart';
import 'package:gym_app/features/member/payment/data/payment_repository.dart';
import 'package:gym_app/features/member/payment/ui/payment_webview_screen.dart';

class CoachProfileScreenNeo extends StatefulWidget {
  final CoachModel coach;
  const CoachProfileScreenNeo({super.key, required this.coach});

  @override
  State<CoachProfileScreenNeo> createState() => _CoachProfileScreenNeoState();
}

class _CoachProfileScreenNeoState extends State<CoachProfileScreenNeo> {
  bool _hiring = false;

  Future<void> _hire() async {
    if (_hiring) return;
    setState(() => _hiring = true);
    try {
      final result = await PaymentRepository.initiateCoachPayment(coachId: widget.coach.id);
      if (!mounted) return;
      context.push(PaymentWebviewScreen.routeName, extra: {
        'payment_url': result['payment_url'] as String,
        'coach_name': result['coach_name'] as String? ?? widget.coach.name,
        'total_amount': result['total_amount'],
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: NeoColors.magenta,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _hiring = false);
    }
  }

  void _showHireSheet() {
    final coach = widget.coach;
    final platformFee = coach.price * 0.05;
    const processingFee = 5.0;
    final total = coach.price + platformFee + processingFee;

    showModalBottomSheet(
      context: context,
      backgroundColor: NeoColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(0))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 3.w, height: 18.h, color: NeoColors.cyan),
              hGap(8),
              Text('ORDER SUMMARY', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
            ]),
            vGap(20),
            _FeeRow(label: 'Coach plan', value: '${coach.price.toStringAsFixed(0)} EGP'),
            vGap(10),
            _FeeRow(label: 'Platform fee (5%)', value: '${platformFee.toStringAsFixed(0)} EGP'),
            vGap(10),
            _FeeRow(label: 'Processing fee', value: '${processingFee.toStringAsFixed(0)} EGP'),
            vGap(14),
            Container(height: 1, color: NeoColors.outlineVariant),
            vGap(14),
            Row(children: [
              Text('TOTAL', style: NeoTextStyles.headlineSm),
              const Spacer(),
              Text('${total.toStringAsFixed(0)} EGP',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 20.sp, fontWeight: FontWeight.w700, color: NeoColors.lime,
                      shadows: [Shadow(color: NeoColors.lime.withValues(alpha: 0.5), blurRadius: 8)])),
            ]),
            vGap(20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _hire();
              },
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  color: NeoColors.cyan,
                  boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.4), blurRadius: 20)],
                ),
                child: Center(child: _hiring
                    ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                    : Text('CONFIRM & PAY',
                        style: GoogleFonts.anton(fontSize: 16.sp, color: Colors.black))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coach = widget.coach;
    final stars = coach.rating.clamp(0, 5).toDouble();

    return Scaffold(
      backgroundColor: NeoColors.bg,
      body: CustomScrollView(
        slivers: [
          _NeoHeroSliver(coach: coach),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    ...List.generate(5, (i) => Icon(
                      i < stars.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: NeoColors.lime,
                      size: 16.r,
                    )),
                    hGap(6),
                    Text('${coach.rating.toStringAsFixed(1)} (${coach.reviewsCount} reviews)',
                        style: NeoTextStyles.dataSm.copyWith(color: NeoColors.onSurfaceVariant)),
                  ]),
                  vGap(14),
                  if (coach.coachType != null || coach.jobTitle.isNotEmpty) ...[
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        if (coach.jobTitle.isNotEmpty)
                          _NeoChip(label: coach.jobTitle, color: NeoColors.cyan),
                        if (coach.coachType != null)
                          _NeoChip(label: coach.coachType!.toUpperCase(), color: NeoColors.lime),
                      ],
                    ),
                    vGap(16),
                  ],
                  Row(children: [
                    _StatTile(label: 'PRICE', value: coach.price.toStringAsFixed(0), unit: 'EGP', color: NeoColors.lime),
                    hGap(8),
                    _StatTile(label: 'DELIVERY', value: coach.turnaround, unit: '', color: NeoColors.cyan),
                    hGap(8),
                    _StatTile(label: 'RATING', value: coach.rating.toStringAsFixed(1), unit: '/5', color: NeoColors.magenta),
                  ]),
                  vGap(20),
                  if (coach.bio.isNotEmpty) ...[
                    Row(children: [
                      Container(width: 3.w, height: 16.h, color: NeoColors.cyan),
                      hGap(8),
                      Text('ABOUT', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                    ]),
                    vGap(10),
                    Text(coach.bio, style: NeoTextStyles.bodyLg.copyWith(height: 1.6, color: NeoColors.onSurfaceVariant)),
                    vGap(20),
                  ],
                  Row(children: [
                    Container(width: 3.w, height: 16.h, color: NeoColors.cyan),
                    hGap(8),
                    Text('WHAT YOU GET', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                  ]),
                  vGap(12),
                  _BenefitRow(icon: Icons.fitness_center, color: NeoColors.cyan, label: coach.service),
                  vGap(8),
                  _BenefitRow(icon: Icons.timer_outlined, color: NeoColors.lime, label: 'Plan delivered in ${coach.turnaround}'),
                  vGap(8),
                  _BenefitRow(icon: Icons.message_outlined, color: NeoColors.magenta, label: 'Direct messaging with your coach'),
                  vGap(8),
                  _BenefitRow(icon: Icons.track_changes, color: NeoColors.onSurface, label: 'Progress tracking & plan adjustments'),
                  vGap(100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _NeoHireBar(coach: coach, hiring: _hiring, onHire: _showHireSheet),
    );
  }
}

class _NeoHeroSliver extends StatelessWidget {
  final CoachModel coach;
  const _NeoHeroSliver({required this.coach});

  @override
  Widget build(BuildContext context) {
    final initials = coach.name.trim().split(' ').take(2).map((w) => w.isEmpty ? '' : w[0].toUpperCase()).join();
    return SliverAppBar(
      expandedHeight: 260.h,
      pinned: true,
      backgroundColor: NeoColors.bg,
      iconTheme: const IconThemeData(color: NeoColors.cyan),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (coach.avatarUrl != null && coach.avatarUrl!.isNotEmpty)
              Image.network(coach.avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: NeoColors.surfaceHigh))
            else
              Container(
                color: NeoColors.surfaceHigh,
                child: Center(
                  child: Text(initials,
                      style: GoogleFonts.anton(fontSize: 80.sp, color: NeoColors.cyan.withValues(alpha: 0.3))),
                ),
              ),
            DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, NeoColors.bg],
                stops: const [0.4, 1.0],
              ),
            )),
            Positioned(
              left: 16.w,
              bottom: 16.h,
              right: 16.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coach.name.toUpperCase(),
                      style: NeoTextStyles.headlineLg.copyWith(
                          color: NeoColors.onSurface,
                          shadows: [Shadow(color: NeoColors.bg.withValues(alpha: 0.8), blurRadius: 8)])),
                  vGap(2),
                  Text(coach.jobTitle,
                      style: NeoTextStyles.bodySm.copyWith(color: NeoColors.cyan)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NeoHireBar extends StatelessWidget {
  final CoachModel coach;
  final bool hiring;
  final VoidCallback onHire;
  const _NeoHireBar({required this.coach, required this.hiring, required this.onHire});

  @override
  Widget build(BuildContext context) {
    final platformFee = coach.price * 0.05;
    const processingFee = 5.0;
    final total = coach.price + platformFee + processingFee;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          decoration: BoxDecoration(
            color: NeoColors.surface.withValues(alpha: 0.9),
            border: Border(top: BorderSide(color: NeoColors.cyan.withValues(alpha: 0.2))),
          ),
          child: coach.isSubscribed
              ? Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: NeoColors.lime),
                    color: NeoColors.lime.withValues(alpha: 0.08),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, color: NeoColors.lime, size: 18.r),
                      hGap(8),
                      Text('ALREADY SUBSCRIBED', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.lime)),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TOTAL', style: NeoTextStyles.labelCaps),
                        Text('${total.toStringAsFixed(0)} EGP',
                            style: GoogleFonts.jetBrainsMono(
                                fontSize: 20.sp, fontWeight: FontWeight.w700, color: NeoColors.lime)),
                      ],
                    ),
                    hGap(16),
                    Expanded(
                      child: GestureDetector(
                        onTap: hiring ? null : onHire,
                        child: Container(
                          height: 52.h,
                          decoration: BoxDecoration(
                            color: NeoColors.cyan,
                            boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.4), blurRadius: 16)],
                          ),
                          child: Center(
                            child: hiring
                                ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                                : Text('HIRE COACH',
                                    style: GoogleFonts.anton(fontSize: 16.sp, color: Colors.black)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FeeRow extends StatelessWidget {
  final String label, value;
  const _FeeRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label, style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurfaceVariant))),
      Text(value, style: NeoTextStyles.dataSm.copyWith(color: NeoColors.onSurface)),
    ]);
  }
}

class _StatTile extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: const Color(0x66201F21),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(label, style: NeoTextStyles.labelCaps.copyWith(fontSize: 9.sp)),
                vGap(4),
                RichText(text: TextSpan(children: [
                  TextSpan(text: value,
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 16.sp, fontWeight: FontWeight.w700, color: color)),
                  if (unit.isNotEmpty)
                    TextSpan(text: ' $unit',
                        style: NeoTextStyles.dataSm.copyWith(fontSize: 10.sp)),
                ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _NeoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label, style: NeoTextStyles.labelCaps.copyWith(color: color)),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _BenefitRow({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 14.r),
        ),
        hGap(10),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(label, style: NeoTextStyles.bodySm.copyWith(height: 1.4, color: NeoColors.onSurfaceVariant)),
          ),
        ),
      ],
    );
  }
}
