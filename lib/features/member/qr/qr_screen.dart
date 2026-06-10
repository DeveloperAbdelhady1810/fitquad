import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

void showQrSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: context.read<MemberCubit>(),
      child: const _QrSheet(),
    ),
  );
}

class _QrSheet extends StatefulWidget {
  const _QrSheet();

  @override
  State<_QrSheet> createState() => _QrSheetState();
}

class _QrSheetState extends State<_QrSheet> {
  List<Map<String, dynamic>> _memberships = [];
  bool _loading = true;
  Map<String, dynamic>? _selectedGym;

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  Future<void> _loadMemberships() async {
    try {
      final res = await ApiClient.get('/member/gym-memberships');
      final list = (res['data'] as List?) ?? [];
      final active = list
          .whereType<Map<String, dynamic>>()
          .where((m) {
            final s = m['status'] as String? ?? '';
            return s == 'active' || s == 'frozen';
          })
          .toList();

      if (mounted) {
        setState(() {
          _memberships = active;
          // Auto-select if only one gym
          if (active.length == 1) {
            _selectedGym = active.first['gym'] as Map<String, dynamic>?;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final memberId =
            state is MemberLoaded ? (state.member.id?.toString() ?? '—') : '—';
        final name =
            state is MemberLoaded ? (state.member.name ?? 'Member') : 'Member';

        // QR priority:
        // 1. external_id from the synced/pre-registered gym membership (e.g. "GLD-2024-001234")
        // 2. "{gymSlug}-{memberId}" (gym-encoded format)
        // 3. legacy qr_code token
        String qrData;
        if (_selectedGym != null && memberId != '—') {
          // Find the membership for the selected gym to get external_id
          final selectedGymId = _selectedGym!['id'];
          final matchingMembership = _memberships.firstWhere(
            (m) => (m['gym']?['id']) == selectedGymId,
            orElse: () => <String, dynamic>{},
          );
          final externalId = matchingMembership['external_id'] as String?;
          if (externalId != null && externalId.isNotEmpty) {
            qrData = externalId;
          } else {
            final slug = _selectedGym!['slug'] as String? ?? '';
            qrData = slug.isNotEmpty ? '$slug-$memberId' : memberId;
          }
        } else if (state is MemberLoaded) {
          qrData = state.member.qrCode ?? state.member.id?.toString() ?? 'MEMBER';
        } else {
          qrData = 'MEMBER';
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 32.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              vGap(20),

              // Header
              Text('Your Gym QR Code', style: AppTextStyles.font16WhiteBold),
              vGap(4),
              Text(name, style: AppTextStyles.font14GreyRegular),
              vGap(20),

              if (_loading)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: const CircularProgressIndicator(color: AppColors.teal),
                )
              else if (_memberships.isEmpty)
                // No gym subscriptions — show QR directly
                _QrCard(qrData: qrData, memberId: memberId, gymName: null)
              else if (_selectedGym != null)
                // Gym selected — show QR with gym context + back option
                Column(
                  children: [
                    _GymChip(
                      gym: _selectedGym!,
                      onClear: _memberships.length > 1
                          ? () => setState(() => _selectedGym = null)
                          : null,
                    ),
                    vGap(16),
                    _QrCard(
                      qrData: qrData,
                      memberId: memberId,
                      gymName: _selectedGym!['name'] as String?,
                    ),
                  ],
                )
              else
                // Multiple gyms — show selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Which gym are you going to?',
                      style: AppTextStyles.font14WhiteRegular
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    vGap(12),
                    ..._memberships.map((m) {
                      final gym = m['gym'] as Map<String, dynamic>? ?? {};
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGym = gym),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: AppColors.teal.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.fitness_center,
                                  color: AppColors.teal, size: 18.r),
                              hGap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(gym['name'] ?? 'Gym',
                                        style:
                                            AppTextStyles.font14WhiteRegular),
                                    Text(gym['city'] ?? '',
                                        style: AppTextStyles.font14GreyRegular
                                            .copyWith(fontSize: 11.sp)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: AppColors.grey, size: 18.r),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),

              vGap(8),
            ],
          ),
        );
      },
    );
  }
}

class _QrCard extends StatelessWidget {
  final String qrData;
  final String memberId;
  final String? gymName;

  const _QrCard(
      {required this.qrData, required this.memberId, required this.gymName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 200.r,
          ),
        ),
        vGap(16),
        Text(
          gymName != null
              ? 'Show this at $gymName reception'
              : 'Show this at the gym reception',
          style: AppTextStyles.font14GreyRegular,
          textAlign: TextAlign.center,
        ),
        vGap(4),
        Text(
          'Member ID: $memberId',
          style: AppTextStyles.font14GreyRegular
              .copyWith(color: AppColors.teal, fontSize: 11.sp),
        ),
        vGap(2),
        Text(
          qrData,
          style: AppTextStyles.font14GreyRegular.copyWith(
            color: AppColors.grey,
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GymChip extends StatelessWidget {
  final Map<String, dynamic> gym;
  final VoidCallback? onClear;

  const _GymChip({required this.gym, this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, color: AppColors.teal, size: 14.r),
          hGap(6),
          Text(gym['name'] ?? 'Gym',
              style: AppTextStyles.font14GreyRegular
                  .copyWith(color: AppColors.teal, fontSize: 12.sp)),
          if (onClear != null) ...[
            hGap(6),
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close, color: AppColors.teal, size: 14.r),
            ),
          ],
        ],
      ),
    );
  }
}
