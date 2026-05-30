import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/app_decoration.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../data/partner_gym_repository.dart';
import '../models/partner_gym_model.dart';
import 'gym_detail_screen.dart';
import 'my_gym_memberships_screen.dart';

class PartnerGymsScreen extends StatefulWidget {
  static const routeName = '/partner-gyms';

  const PartnerGymsScreen({super.key});

  @override
  State<PartnerGymsScreen> createState() => _PartnerGymsScreenState();
}

class _PartnerGymsScreenState extends State<PartnerGymsScreen> {
  List<PartnerGymModel> _gyms = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final gyms = await PartnerGymRepository.getGyms();
      if (mounted) setState(() { _gyms = gyms; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Partner Gyms', style: AppTextStyles.font16WhiteBold),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const MyGymMembershipsScreen())),
            icon: Icon(Icons.card_membership, color: AppColors.teal, size: 18.r),
            label: Text('My Plans',
                style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
          : _error != null
              ? _ErrorState(onRetry: _load)
              : _gyms.isEmpty
                  ? _EmptyState()
                  : RefreshIndicator(
                      color: AppColors.teal,
                      onRefresh: _load,
                      child: ListView.separated(
                        padding: EdgeInsets.all(16.r),
                        itemCount: _gyms.length,
                        separatorBuilder: (_, __) => vGap(12),
                        itemBuilder: (_, i) => _GymCard(
                          gym: _gyms[i],
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => GymDetailScreen(gymId: _gyms[i].id)),
                            );
                            _load();
                          },
                        ),
                      ),
                    ),
    );
  }
}

class _GymCard extends StatelessWidget {
  final PartnerGymModel gym;
  final VoidCallback onTap;

  const _GymCard({required this.gym, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final crowdColor = gym.crowdLevel == 'crowded'
        ? Colors.redAccent
        : gym.crowdLevel == 'moderate'
            ? const Color(0xFFFFD700)
            : AppColors.emerald;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.containerDecoration,
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo / Avatar
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: gym.logo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(gym.logo!, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _gymIcon()))
                      : _gymIcon(),
                ),
                hGap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gym.name, style: AppTextStyles.font16WhiteBold),
                      vGap(2),
                      Text('${gym.address}, ${gym.city}',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.grey, size: 20.r),
              ],
            ),
            vGap(12),
            Row(
              children: [
                // Crowd level
                _Badge(
                  icon: Icons.people_outline,
                  label: '${gym.attendanceToday} today · ${gym.crowdLevel}',
                  color: crowdColor,
                ),
                hGap(8),
                // Plans count
                if (gym.plans.isNotEmpty)
                  _Badge(
                    icon: Icons.credit_card_outlined,
                    label: '${gym.plans.length} plans from ${_minPrice(gym)} EGP',
                    color: AppColors.teal,
                  ),
              ],
            ),
            if (gym.amenities.isNotEmpty) ...[
              vGap(10),
              Wrap(
                spacing: 6.w,
                children: gym.amenities
                    .take(4)
                    .map((a) => _Chip(label: a))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _gymIcon() => Icon(Icons.fitness_center, color: AppColors.teal, size: 26.r);

  String _minPrice(PartnerGymModel gym) {
    if (gym.plans.isEmpty) return '—';
    final min = gym.plans.map((p) => p.price).reduce((a, b) => a < b ? a : b);
    return min.toStringAsFixed(0);
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.r),
          hGap(4),
          Text(label,
              style: AppTextStyles.font14GreyRegular
                  .copyWith(color: color, fontSize: 11.sp)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label,
          style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.store_outlined, color: AppColors.grey, size: 56.r),
            vGap(12),
            Text('No partner gyms yet',
                style: AppTextStyles.font16WhiteBold),
            vGap(6),
            Text('Check back soon!',
                style: AppTextStyles.font14GreyRegular),
          ],
        ),
      );
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: AppColors.grey, size: 48.r),
            vGap(12),
            Text('Failed to load gyms', style: AppTextStyles.font16WhiteBold),
            vGap(12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
              child: Text('Retry', style: AppTextStyles.font14WhiteRegular),
            ),
          ],
        ),
      );
}
