import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/partner_gyms/data/partner_gym_repository.dart';
import 'package:gym_app/features/member/partner_gyms/models/gym_membership_model.dart';
import 'package:gym_app/features/member/partner_gyms/models/partner_gym_model.dart';
import 'package:gym_app/features/member/payment/ui/payment_webview_screen.dart';

class GymDetailScreenNeo extends StatefulWidget {
  final int gymId;
  const GymDetailScreenNeo({super.key, required this.gymId});

  @override
  State<GymDetailScreenNeo> createState() => _GymDetailScreenNeoState();
}

class _GymDetailScreenNeoState extends State<GymDetailScreenNeo> {
  PartnerGymModel? _gym;
  GymMembershipModel? _membership;
  bool _loading = true;
  String? _error;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        PartnerGymRepository.getGymDetail(widget.gymId),
        PartnerGymRepository.getMemberships(),
      ]);
      final gymData = results[0] as Map<String, dynamic>;
      final memberships = results[1] as List<GymMembershipModel>;
      final gym = PartnerGymModel.fromJson(gymData);
      final membership = memberships.cast<GymMembershipModel?>().firstWhere(
          (m) => m?.gym?.id == widget.gymId, orElse: () => null);
      if (mounted) setState(() { _gym = gym; _membership = membership; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _freeze() async {
    if (_membership == null || _actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      final updated = await PartnerGymRepository.freeze(_membership!.id);
      if (mounted) setState(() { _membership = updated; _actionLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _unfreeze() async {
    if (_membership == null || _actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      final updated = await PartnerGymRepository.unfreeze(_membership!.id);
      if (mounted) setState(() { _membership = updated; _actionLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        _showError(e.toString());
      }
    }
  }

  Future<void> _startPayment(GymPlanModel plan) async {
    if (_actionLoading) return;
    setState(() => _actionLoading = true);
    try {
      final result = await PartnerGymRepository.initiateGymPayment(plan.id);
      if (!mounted) return;
      setState(() => _actionLoading = false);
      context.push(PaymentWebviewScreen.routeName, extra: {
        'payment_url': result['payment_url'] as String,
        'coach_name': _gym?.name ?? '',
        'total_amount': plan.price,
      });
    } catch (e) {
      if (mounted) {
        setState(() => _actionLoading = false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: NeoColors.magenta,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showSubscribeSheet(GymPlanModel plan) {
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
              Text('SUBSCRIBE', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
            ]),
            vGap(16),
            _FeeRow(label: plan.name, value: '${plan.price.toStringAsFixed(0)} EGP'),
            vGap(8),
            _FeeRow(label: 'Duration', value: '${plan.durationDays} days'),
            vGap(8),
            _FeeRow(label: 'Max freeze', value: '${plan.maxFreezeDays} days'),
            if (plan.features.isNotEmpty) ...[
              vGap(12),
              Container(height: 1, color: NeoColors.outlineVariant),
              vGap(12),
              ...plan.features.map((f) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(children: [
                  Icon(Icons.check, color: NeoColors.lime, size: 14.r),
                  hGap(8),
                  Expanded(child: Text(f, style: NeoTextStyles.bodySm)),
                ]),
              )),
            ],
            vGap(16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _startPayment(plan);
              },
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  color: NeoColors.cyan,
                  boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.4), blurRadius: 20)],
                ),
                child: Center(
                  child: Text('PROCEED TO PAYMENT',
                      style: GoogleFonts.anton(fontSize: 16.sp, color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: NeoColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(0))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 3.w, height: 18.h, color: NeoColors.cyan),
              hGap(8),
              Text('SYNC MEMBERSHIP', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
            ]),
            vGap(12),
            Text('Enter your membership ID from the gym to sync your subscription.',
                style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurfaceVariant)),
            vGap(16),
            TextField(
              controller: ctrl,
              style: GoogleFonts.jetBrainsMono(color: NeoColors.onSurface, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'MEMBERSHIP ID',
                hintStyle: GoogleFonts.jetBrainsMono(color: NeoColors.outline, fontSize: 14.sp),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: NeoColors.cyan.withValues(alpha: 0.4))),
                focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: NeoColors.cyan)),
              ),
            ),
            vGap(16),
            GestureDetector(
              onTap: () async {
                final id = ctrl.text.trim();
                if (id.isEmpty) return;
                Navigator.pop(context);
                setState(() => _actionLoading = true);
                try {
                  final membership = await PartnerGymRepository.syncSubscription(widget.gymId, id);
                  if (mounted) setState(() { _membership = membership; _actionLoading = false; });
                } catch (e) {
                  if (mounted) {
                    setState(() => _actionLoading = false);
                    _showError(e.toString());
                  }
                }
              },
              child: Container(
                width: double.infinity,
                height: 52.h,
                decoration: BoxDecoration(
                  border: Border.all(color: NeoColors.cyan),
                  color: NeoColors.cyan.withValues(alpha: 0.08),
                ),
                child: Center(
                  child: Text('SYNC', style: GoogleFonts.anton(fontSize: 16.sp, color: NeoColors.cyan)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: NeoColors.bg,
        body: Center(child: CircularProgressIndicator(color: NeoColors.cyan)),
      );
    }
    if (_error != null || _gym == null) {
      return Scaffold(
        backgroundColor: NeoColors.bg,
        appBar: AppBar(
          backgroundColor: NeoColors.bg,
          elevation: 0,
          iconTheme: const IconThemeData(color: NeoColors.cyan),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off, color: NeoColors.outline, size: 40.r),
              vGap(12),
              Text('FAILED TO LOAD', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.outline)),
              vGap(12),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(border: Border.all(color: NeoColors.cyan)),
                  child: Text('RETRY', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final gym = _gym!;
    final membership = _membership;
    final allPhotos = gym.photos;
    final (crowdColor, crowdText) = switch (gym.crowdLevel.toLowerCase()) {
      'quiet' => (NeoColors.lime, 'QUIET'),
      'busy' || 'crowded' => (NeoColors.magenta, 'BUSY'),
      _ => (NeoColors.cyan, 'MODERATE'),
    };
    final crowdPct = gym.capacity > 0 ? (gym.attendanceToday / gym.capacity).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: NeoColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240.h,
            pinned: true,
            backgroundColor: NeoColors.bg,
            iconTheme: const IconThemeData(color: NeoColors.cyan),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (allPhotos.isNotEmpty)
                    Image.network(allPhotos.first.url, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: NeoColors.surfaceHigh))
                  else if (gym.logo != null)
                    Image.network(gym.logo!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: NeoColors.surfaceHigh))
                  else
                    Container(
                      color: NeoColors.surfaceHigh,
                      child: Center(child: Icon(Icons.fitness_center, color: NeoColors.outline, size: 60.r)),
                    ),
                  DecoratedBox(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, NeoColors.bg],
                      stops: const [0.3, 1.0],
                    ),
                  )),
                  Positioned(
                    top: 8.h, right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: crowdColor.withValues(alpha: 0.2),
                        border: Border.all(color: crowdColor),
                        boxShadow: [BoxShadow(color: crowdColor.withValues(alpha: 0.3), blurRadius: 6)],
                      ),
                      child: Text(crowdText, style: NeoTextStyles.labelCaps.copyWith(color: crowdColor)),
                    ),
                  ),
                  Positioned(
                    left: 16.w, bottom: 12.h, right: 16.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gym.name.toUpperCase(),
                            style: NeoTextStyles.headlineLg.copyWith(
                                shadows: [Shadow(color: NeoColors.bg.withValues(alpha: 0.8), blurRadius: 8)])),
                        Row(children: [
                          Icon(Icons.location_on, color: NeoColors.cyan, size: 12.r),
                          hGap(4),
                          Text('${gym.address}, ${gym.city}',
                              style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurfaceVariant)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (membership != null) ...[
                    _MembershipBanner(
                      membership: membership,
                      actionLoading: _actionLoading,
                      onFreeze: _freeze,
                      onUnfreeze: _unfreeze,
                    ),
                    vGap(16),
                  ],

                  // Info card
                  _NeoGlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(14.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (gym.description != null && gym.description!.isNotEmpty) ...[
                            Text('ABOUT', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                            vGap(8),
                            Text(gym.description!,
                                style: NeoTextStyles.bodySm.copyWith(
                                    height: 1.6, color: NeoColors.onSurfaceVariant)),
                            vGap(12),
                          ],
                          if (gym.phone != null) ...[
                            Row(children: [
                              Icon(Icons.phone, color: NeoColors.cyan, size: 14.r),
                              hGap(8),
                              Text(gym.phone!, style: NeoTextStyles.bodySm),
                            ]),
                            vGap(8),
                          ],
                          Row(children: [
                            Icon(Icons.people_outline, color: NeoColors.cyan, size: 14.r),
                            hGap(8),
                            Text('Capacity: ${gym.capacity} members',
                                style: NeoTextStyles.bodySm),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  vGap(16),

                  // Crowd meter
                  _SectionHeader(label: 'CURRENT CROWD'),
                  vGap(10),
                  _NeoGlassCard(
                    child: Padding(
                      padding: EdgeInsets.all(14.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text('${gym.attendanceToday} / ${gym.capacity}',
                                style: GoogleFonts.jetBrainsMono(
                                    fontSize: 16.sp, fontWeight: FontWeight.w700, color: crowdColor)),
                            hGap(8),
                            Text('people right now', style: NeoTextStyles.bodySm),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: crowdColor.withValues(alpha: 0.1),
                                border: Border.all(color: crowdColor.withValues(alpha: 0.5)),
                              ),
                              child: Text(crowdText, style: NeoTextStyles.labelCaps.copyWith(color: crowdColor, fontSize: 9.sp)),
                            ),
                          ]),
                          vGap(10),
                          ClipRect(
                            child: LinearProgressIndicator(
                              value: crowdPct,
                              minHeight: 6.h,
                              backgroundColor: NeoColors.surfaceTop,
                              valueColor: AlwaysStoppedAnimation<Color>(crowdColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  vGap(16),

                  // Amenities
                  if (gym.amenities.isNotEmpty) ...[
                    _SectionHeader(label: 'AMENITIES'),
                    vGap(10),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: gym.amenities.map((a) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: NeoColors.cyan.withValues(alpha: 0.08),
                          border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Text(a.toUpperCase(), style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                      )).toList(),
                    ),
                    vGap(16),
                  ],

                  // Subscription plans
                  if (gym.plans.isNotEmpty) ...[
                    Row(
                      children: [
                        _SectionHeader(label: 'MEMBERSHIP PLANS'),
                        const Spacer(),
                        if (membership == null)
                          GestureDetector(
                            onTap: _showSyncSheet,
                            child: Text('SYNC EXISTING ›',
                                style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.magenta)),
                          ),
                      ],
                    ),
                    vGap(10),
                    ...gym.plans.map((plan) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _PlanCard(
                        plan: plan,
                        isCurrent: membership?.plan?.id == plan.id && (membership?.isActive == true || membership?.isFrozen == true),
                        onSubscribe: membership == null ? () => _showSubscribeSheet(plan) : null,
                        actionLoading: _actionLoading,
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MembershipBanner extends StatelessWidget {
  final GymMembershipModel membership;
  final bool actionLoading;
  final VoidCallback onFreeze;
  final VoidCallback onUnfreeze;
  const _MembershipBanner({
    required this.membership,
    required this.actionLoading,
    required this.onFreeze,
    required this.onUnfreeze,
  });

  @override
  Widget build(BuildContext context) {
    final (bannerColor, bannerLabel) = membership.isFrozen
        ? (NeoColors.cyan, 'FROZEN')
        : membership.isActive
            ? (NeoColors.lime, 'ACTIVE')
            : membership.isExpired
                ? (NeoColors.outline, 'EXPIRED')
                : (NeoColors.magenta, 'CANCELLED');

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: bannerColor.withValues(alpha: 0.08),
            border: Border.all(color: bannerColor.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: bannerColor.withValues(alpha: 0.15),
                    border: Border.all(color: bannerColor),
                  ),
                  child: Text('MEMBERSHIP $bannerLabel',
                      style: NeoTextStyles.labelCaps.copyWith(color: bannerColor)),
                ),
                const Spacer(),
                Text('${membership.daysRemaining} days left',
                    style: NeoTextStyles.dataSm.copyWith(color: NeoColors.onSurfaceVariant)),
              ]),
              vGap(8),
              Text('Expires ${membership.endDate}',
                  style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurfaceVariant)),
              if (membership.isActive || membership.isFrozen) ...[
                vGap(10),
                Row(children: [
                  if (membership.isActive)
                    Expanded(
                      child: GestureDetector(
                        onTap: actionLoading ? null : onFreeze,
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: NeoColors.cyan),
                            color: NeoColors.cyan.withValues(alpha: 0.08),
                          ),
                          child: Center(
                            child: actionLoading
                                ? SizedBox(width: 16.r, height: 16.r,
                                    child: const CircularProgressIndicator(color: NeoColors.cyan, strokeWidth: 2))
                                : Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.ac_unit, color: NeoColors.cyan, size: 14.r),
                                    hGap(6),
                                    Text('FREEZE', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                                  ]),
                          ),
                        ),
                      ),
                    ),
                  if (membership.isFrozen)
                    Expanded(
                      child: GestureDetector(
                        onTap: actionLoading ? null : onUnfreeze,
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: NeoColors.lime),
                            color: NeoColors.lime.withValues(alpha: 0.08),
                          ),
                          child: Center(
                            child: actionLoading
                                ? SizedBox(width: 16.r, height: 16.r,
                                    child: const CircularProgressIndicator(color: NeoColors.lime, strokeWidth: 2))
                                : Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.play_arrow, color: NeoColors.lime, size: 14.r),
                                    hGap(6),
                                    Text('UNFREEZE', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime)),
                                  ]),
                          ),
                        ),
                      ),
                    ),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final GymPlanModel plan;
  final bool isCurrent;
  final VoidCallback? onSubscribe;
  final bool actionLoading;
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    this.onSubscribe,
    required this.actionLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: isCurrent
                ? NeoColors.lime.withValues(alpha: 0.06)
                : const Color(0x66201F21),
            border: Border.all(
              color: isCurrent ? NeoColors.lime.withValues(alpha: 0.5) : NeoColors.cyan.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(plan.name.toUpperCase(),
                        style: NeoTextStyles.headlineSm.copyWith(
                            color: isCurrent ? NeoColors.lime : NeoColors.onSurface)),
                    vGap(2),
                    Text('${plan.durationDays} days · freeze up to ${plan.maxFreezeDays}d',
                        style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurfaceVariant)),
                  ]),
                ),
                Text('${plan.price.toStringAsFixed(0)} EGP',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 18.sp, fontWeight: FontWeight.w700,
                        color: isCurrent ? NeoColors.lime : NeoColors.cyan)),
              ]),
              if (plan.features.isNotEmpty) ...[
                vGap(10),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: plan.features.take(3).map((f) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: NeoColors.lime, size: 12.r),
                      hGap(4),
                      Text(f, style: NeoTextStyles.dataSm.copyWith(fontSize: 11.sp, color: NeoColors.onSurfaceVariant)),
                    ],
                  )).toList(),
                ),
              ],
              if (!isCurrent && onSubscribe != null) ...[
                vGap(10),
                GestureDetector(
                  onTap: actionLoading ? null : onSubscribe,
                  child: Container(
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: NeoColors.cyan,
                      boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.3), blurRadius: 8)],
                    ),
                    child: Center(
                      child: actionLoading
                          ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                          : Text('SUBSCRIBE',
                              style: GoogleFonts.anton(fontSize: 13.sp, color: Colors.black)),
                    ),
                  ),
                ),
              ],
              if (isCurrent)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_outline, color: NeoColors.lime, size: 14.r),
                    hGap(6),
                    Text('CURRENT PLAN', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime)),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 3.w, height: 16.h, color: NeoColors.cyan),
      hGap(8),
      Text(label, style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
    ]);
  }
}

class _NeoGlassCard extends StatelessWidget {
  final Widget child;
  const _NeoGlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x66201F21),
            border: Border.all(color: const Color(0x2600DCE6)),
          ),
          child: child,
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
