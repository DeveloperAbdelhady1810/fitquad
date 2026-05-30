import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/app_decoration.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/partner_gym_repository.dart';
import '../models/gym_membership_model.dart';
import '../models/partner_gym_model.dart';
import 'gym_support_screen.dart';

class GymDetailScreen extends StatefulWidget {
  final int gymId;
  const GymDetailScreen({super.key, required this.gymId});

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  PartnerGymModel? _gym;
  GymMembershipModel? _membership;
  bool _loading = true;
  bool _subscribing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await PartnerGymRepository.getGymDetail(widget.gymId);
      final gymJson = raw['gym'] as Map<String, dynamic>;
      final membershipJson = raw['my_membership'] as Map<String, dynamic>?;
      final plansJson = (gymJson['subscription_plans'] as List?) ?? [];
      final enriched = {
        ...gymJson,
        'plans': plansJson,
        'attendance_today': raw['attendance_today'],
        'crowd_level': raw['crowd_level'],
      };
      if (mounted) {
        setState(() {
          _gym = PartnerGymModel.fromJson(enriched);
          _membership = membershipJson != null
              ? GymMembershipModel.fromJson(membershipJson)
              : null;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
      }
    }
  }

  Future<void> _subscribe(GymPlanModel plan) async {
    setState(() => _subscribing = true);
    try {
      await PartnerGymRepository.subscribe(plan.id, plan.price);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Subscribed successfully!'),
            backgroundColor: AppColors.teal));
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
      }
    } finally {
      if (mounted) setState(() => _subscribing = false);
    }
  }

  void _showSubscribeSheet(GymPlanModel plan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subscribe to ${plan.name}',
                style: AppTextStyles.font16WhiteBold),
            vGap(16),
            _InfoRow(label: 'Price', value: '${plan.price.toStringAsFixed(0)} EGP'),
            _InfoRow(label: 'Duration', value: '${plan.durationDays} days'),
            _InfoRow(label: 'Max freeze', value: '${plan.maxFreezeDays} days'),
            if (plan.features.isNotEmpty) ...[
              vGap(12),
              Text('Includes', style: AppTextStyles.font14GreyRegular),
              vGap(6),
              ...plan.features.map((f) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline,
                          color: AppColors.teal, size: 14.r),
                      hGap(6),
                      Text(f,
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 13.sp)),
                    ]),
                  )),
            ],
            vGap(20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _subscribing
                    ? null
                    : () {
                        Navigator.pop(context);
                        _subscribe(plan);
                      },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r))),
                child: _subscribing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Confirm & Subscribe',
                        style: AppTextStyles.font16WhiteBold),
              ),
            ),
            vGap(8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(backgroundColor: AppColors.primary),
        body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    if (_gym == null) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(backgroundColor: AppColors.primary),
        body: Center(child: Text('Gym not found', style: AppTextStyles.font16WhiteBold)),
      );
    }

    final gym = _gym!;
    final crowdColor = gym.crowdLevel == 'crowded'
        ? Colors.redAccent
        : gym.crowdLevel == 'moderate'
            ? const Color(0xFFFFD700)
            : AppColors.emerald;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.secondary,
            expandedHeight: 180.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(gym.name, style: AppTextStyles.font16WhiteBold),
              background: gym.logo != null
                  ? Image.network(gym.logo!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _logoPlaceholder())
                  : _logoPlaceholder(),
            ),
            actions: [
              if (_membership != null && (_membership!.isActive || _membership!.isFrozen))
                IconButton(
                  icon: Icon(Icons.chat_bubble_outline,
                      color: AppColors.teal, size: 22.r),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GymSupportScreen(
                            gymId: gym.id, gymName: gym.name)),
                  ),
                ),
            ],
          ),
          SliverPadding(
            padding: EdgeInsets.all(16.r),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active membership banner
                if (_membership != null &&
                    (_membership!.isActive || _membership!.isFrozen)) ...[
                  _MembershipBanner(
                    membership: _membership!,
                    gymId: gym.id,
                    gymName: gym.name,
                    onChanged: _load,
                  ),
                  vGap(16),
                ],

                // Location & info
                Container(
                  decoration: AppDecorations.containerDecoration,
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: '${gym.address}, ${gym.city}'),
                      if (gym.phone != null)
                        _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: gym.phone!),
                      if (gym.description != null) ...[
                        vGap(10),
                        Text(gym.description!,
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(fontSize: 13.sp)),
                      ],
                    ],
                  ),
                ),

                vGap(16),

                // Crowd meter
                Container(
                  decoration: AppDecorations.containerDecoration,
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, color: crowdColor, size: 28.r),
                      hGap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${gym.attendanceToday} members here today',
                                style: AppTextStyles.font14WhiteRegular),
                            vGap(4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4.r),
                              child: LinearProgressIndicator(
                                value: gym.capacity > 0
                                    ? (gym.attendanceToday / gym.capacity)
                                        .clamp(0.0, 1.0)
                                    : 0,
                                backgroundColor: Colors.white12,
                                color: crowdColor,
                                minHeight: 6.h,
                              ),
                            ),
                            vGap(4),
                            Text(
                              gym.crowdLevel == 'crowded'
                                  ? 'Crowded — might want to wait'
                                  : gym.crowdLevel == 'moderate'
                                      ? 'Moderate — decent time to go'
                                      : 'Quiet — great time to go!',
                              style: AppTextStyles.font14GreyRegular
                                  .copyWith(color: crowdColor, fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                vGap(16),

                // Amenities
                if (gym.amenities.isNotEmpty) ...[
                  Text('Amenities', style: AppTextStyles.font16WhiteBold),
                  vGap(8),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: gym.amenities
                        .map((a) => _AmenityChip(label: a))
                        .toList(),
                  ),
                  vGap(16),
                ],

                // Subscription plans
                if (_membership == null || _membership!.isExpired || _membership!.isCancelled) ...[
                  Text('Subscription Plans', style: AppTextStyles.font16WhiteBold),
                  vGap(8),
                  if (gym.plans.isEmpty)
                    Text('No plans available yet.',
                        style: AppTextStyles.font14GreyRegular)
                  else
                    ...gym.plans.map((plan) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _PlanCard(
                            plan: plan,
                            onSubscribe: () => _showSubscribeSheet(plan),
                          ),
                        )),
                ],

                vGap(24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoPlaceholder() => Container(
        color: AppColors.secondary,
        child: Center(
            child: Icon(Icons.fitness_center, color: AppColors.teal, size: 56.r)),
      );
}

// ── Membership banner shown when already subscribed ──────────────────────────

class _MembershipBanner extends StatefulWidget {
  final GymMembershipModel membership;
  final int gymId;
  final String gymName;
  final VoidCallback onChanged;

  const _MembershipBanner({
    required this.membership,
    required this.gymId,
    required this.gymName,
    required this.onChanged,
  });

  @override
  State<_MembershipBanner> createState() => _MembershipBannerState();
}

class _MembershipBannerState extends State<_MembershipBanner> {
  bool _busy = false;

  Future<void> _freeze() async {
    setState(() => _busy = true);
    try {
      await PartnerGymRepository.freeze(widget.membership.id);
      widget.onChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unfreeze() async {
    setState(() => _busy = true);
    try {
      await PartnerGymRepository.unfreeze(widget.membership.id);
      widget.onChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.membership;
    final isFrozen = m.isFrozen;
    final statusColor = isFrozen ? const Color(0xFF4D8DBD) : AppColors.teal;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.25), AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isFrozen ? Icons.ac_unit : Icons.verified_outlined,
                  color: statusColor, size: 18.r),
              hGap(6),
              Text(
                isFrozen ? 'Membership Frozen' : 'Active Membership',
                style: AppTextStyles.font14WhiteRegular
                    .copyWith(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          vGap(10),
          _InfoRow(label: 'Plan', value: m.plan?.name ?? '—'),
          _InfoRow(
              label: isFrozen ? 'Frozen since' : 'Expires',
              value: isFrozen ? (m.freezeStartDate ?? '—') : m.endDate),
          if (!isFrozen)
            _InfoRow(label: 'Days remaining', value: '${m.daysRemaining} days'),
          _InfoRow(label: 'Frozen days used',
              value: '${m.totalFrozenDays} / ${m.plan?.maxFreezeDays ?? 30}'),
          vGap(12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : isFrozen
                          ? _unfreeze
                          : _freeze,
                  icon: Icon(
                      isFrozen ? Icons.play_arrow_outlined : Icons.ac_unit_outlined,
                      size: 16.r),
                  label: Text(isFrozen ? 'Unfreeze' : 'Freeze',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: statusColor)),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: statusColor.withOpacity(0.5))),
                ),
              ),
              hGap(10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GymSupportScreen(
                            gymId: widget.gymId, gymName: widget.gymName)),
                  ),
                  icon: Icon(Icons.chat_bubble_outline,
                      color: AppColors.grey, size: 16.r),
                  label: Text('Support',
                      style: AppTextStyles.font14GreyRegular),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white24)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Plan card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final GymPlanModel plan;
  final VoidCallback onSubscribe;

  const _PlanCard({required this.plan, required this.onSubscribe});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.name, style: AppTextStyles.font16WhiteBold),
                vGap(4),
                Text('${plan.durationDays} days · freeze up to ${plan.maxFreezeDays}d',
                    style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp)),
                if (plan.features.isNotEmpty) ...[
                  vGap(6),
                  Text(plan.features.take(2).join(' · '),
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(fontSize: 11.sp, color: AppColors.teal)),
                ],
              ],
            ),
          ),
          hGap(12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${plan.price.toStringAsFixed(0)} EGP',
                  style: AppTextStyles.font16WhiteBold
                      .copyWith(color: AppColors.teal)),
              vGap(6),
              ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Subscribe', style: AppTextStyles.font14WhiteRegular),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;

  const _InfoRow({this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 6.h),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.grey, size: 14.r),
              hGap(6),
            ],
            Text('$label: ',
                style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp)),
            Expanded(
              child: Text(value,
                  style: AppTextStyles.font14WhiteRegular
                      .copyWith(fontSize: 12.sp),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      );
}

class _AmenityChip extends StatelessWidget {
  final String label;
  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.teal.withOpacity(0.3)),
        ),
        child: Text(label,
            style:
                AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal, fontSize: 12.sp)),
      );
}
