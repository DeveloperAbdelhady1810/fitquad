import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/app_decoration.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/partner_gym_repository.dart';
import '../models/gym_membership_model.dart';
import 'guest_passes_screen.dart';
import 'gym_detail_screen.dart';
import 'gym_support_screen.dart';

class MyGymMembershipsScreen extends StatefulWidget {
  static const routeName = '/my-gym-memberships';

  const MyGymMembershipsScreen({super.key});

  @override
  State<MyGymMembershipsScreen> createState() => _MyGymMembershipsScreenState();
}

class _MyGymMembershipsScreenState extends State<MyGymMembershipsScreen> {
  List<GymMembershipModel> _memberships = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await PartnerGymRepository.getMemberships();
      if (mounted) setState(() { _memberships = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _freeze(GymMembershipModel m) async {
    try {
      await PartnerGymRepository.freeze(m.id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    }
  }

  Future<void> _unfreeze(GymMembershipModel m) async {
    try {
      await PartnerGymRepository.unfreeze(m.id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    }
  }

  Future<void> _cancel(GymMembershipModel m) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text('Cancel membership?', style: AppTextStyles.font16WhiteBold),
        content: Text('This cannot be undone.',
            style: AppTextStyles.font14GreyRegular),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('No', style: AppTextStyles.font14GreyRegular)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Yes, cancel',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(color: AppColors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await PartnerGymRepository.cancel(m.id);
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('My Gym Plans', style: AppTextStyles.font16WhiteBold),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : _memberships.isEmpty
              ? _EmptyState()
              : RefreshIndicator(
                  color: AppColors.teal,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: _memberships.length,
                    separatorBuilder: (_, __) => vGap(12),
                    itemBuilder: (_, i) => _MembershipCard(
                      membership: _memberships[i],
                      onFreeze: () => _freeze(_memberships[i]),
                      onUnfreeze: () => _unfreeze(_memberships[i]),
                      onCancel: () => _cancel(_memberships[i]),
                      onViewGym: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GymDetailScreen(
                              gymId: _memberships[i].gym?.id ?? 0),
                        ),
                      ).then((_) => _load()),
                      onSupport: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GymSupportScreen(
                            gymId: _memberships[i].gym?.id ?? 0,
                            gymName: _memberships[i].gym?.name ?? 'Gym',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final GymMembershipModel membership;
  final VoidCallback onFreeze;
  final VoidCallback onUnfreeze;
  final VoidCallback onCancel;
  final VoidCallback onViewGym;
  final VoidCallback onSupport;

  const _MembershipCard({
    required this.membership,
    required this.onFreeze,
    required this.onUnfreeze,
    required this.onCancel,
    required this.onViewGym,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    final m = membership;
    final isActive = m.isActive;
    final isFrozen = m.isFrozen;
    final isInactive = m.isExpired || m.isCancelled;

    final statusColor = isFrozen
        ? const Color(0xFF4D8DBD)
        : isActive
            ? AppColors.teal
            : AppColors.grey;

    final statusLabel = isFrozen
        ? 'Frozen'
        : isActive
            ? 'Active'
            : m.status[0].toUpperCase() + m.status.substring(1);

    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(m.gym?.name ?? 'Gym',
                    style: AppTextStyles.font16WhiteBold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(statusLabel,
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(color: statusColor, fontSize: 11.sp)),
              ),
            ],
          ),
          vGap(10),
          Text(m.plan?.name ?? '—',
              style: AppTextStyles.font14GreyRegular
                  .copyWith(color: AppColors.teal)),
          vGap(8),
          _Row(label: 'Started', value: m.startDate),
          if (isFrozen)
            _Row(label: 'Frozen since', value: m.freezeStartDate ?? '—'),
          _Row(label: 'Expires', value: m.endDate),
          if (isActive) _Row(label: 'Days remaining', value: '${m.daysRemaining} days'),
          _Row(
              label: 'Frozen days used',
              value: '${m.totalFrozenDays} / ${m.plan?.maxFreezeDays ?? 30}'),

          if (!isInactive) ...[
            vGap(12),
            Row(
              children: [
                if (isActive)
                  Expanded(
                    child: _ActionButton(
                      label: 'Freeze',
                      icon: Icons.ac_unit_outlined,
                      color: const Color(0xFF4D8DBD),
                      onTap: onFreeze,
                    ),
                  ),
                if (isFrozen)
                  Expanded(
                    child: _ActionButton(
                      label: 'Unfreeze',
                      icon: Icons.play_arrow_outlined,
                      color: AppColors.teal,
                      onTap: onUnfreeze,
                    ),
                  ),
                hGap(8),
                Expanded(
                  child: _ActionButton(
                    label: 'Support',
                    icon: Icons.chat_bubble_outline,
                    color: AppColors.grey,
                    onTap: onSupport,
                  ),
                ),
                hGap(8),
                Expanded(
                  child: _ActionButton(
                    label: 'Cancel',
                    icon: Icons.cancel_outlined,
                    color: AppColors.red,
                    onTap: onCancel,
                  ),
                ),
              ],
            ),
          ],

          vGap(8),
          Row(
            children: [
              TextButton(
                onPressed: onViewGym,
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text('View gym →',
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(color: AppColors.teal, fontSize: 12.sp)),
              ),
              if (isActive) ...[
                hGap(16),
                TextButton(
                  onPressed: () => context.push(GuestPassesScreen.routeName),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: Text('🎟️ Guest passes →',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: AppColors.teal, fontSize: 12.sp)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: Row(
          children: [
            Text('$label: ',
                style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp)),
            Text(value,
                style: AppTextStyles.font14WhiteRegular.copyWith(fontSize: 12.sp)),
          ],
        ),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 14.r, color: color),
        label: Text(label,
            style: AppTextStyles.font14GreyRegular
                .copyWith(color: color, fontSize: 11.sp)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          side: BorderSide(color: color.withOpacity(0.4)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r)),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.card_membership_outlined,
                color: AppColors.grey, size: 56.r),
            vGap(12),
            Text('No gym memberships yet', style: AppTextStyles.font16WhiteBold),
            vGap(6),
            Text('Browse partner gyms to subscribe',
                style: AppTextStyles.font14GreyRegular),
          ],
        ),
      );
}
