import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/ui/views/login_view.dart';

import '../../../../generated/l10n.dart';

class CoachProfileTab extends StatefulWidget {
  const CoachProfileTab({super.key});

  @override
  State<CoachProfileTab> createState() => _CoachProfileTabState();
}

class _CoachProfileTabState extends State<CoachProfileTab> {
  Map<String, dynamic>? _coachData;
  bool _loading = true;
  bool _available = true;
  bool _savingAvail = false;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.get('/auth/me');
      final user = res['data'] as Map<String, dynamic>? ?? {};
      final coach = user['coach'] as Map<String, dynamic>? ?? {};
      setState(() {
        _coachData = {...user, ...coach};
        _available = coach['is_available'] as bool? ?? true;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() {
      _available = value;
      _savingAvail = true;
    });
    try {
      await ApiClient.put('/auth/profile', {'is_available': value});
    } catch (_) {
      // revert on failure
      if (mounted) setState(() => _available = !value);
    } finally {
      if (mounted) setState(() => _savingAvail = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await AuthRepository.logout();
    } catch (_) {}
    if (mounted) context.go(LoginView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    final name          = _coachData?['name'] as String? ?? 'Coach';
    final specialization = _coachData?['specialization'] as String? ?? 'Personal Trainer';
    final bio           = _coachData?['bio'] as String? ?? '';
    final rating        = (_coachData?['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewsCount  = _coachData?['reviews_count'] as int? ?? 0;
    final price         = (_coachData?['price_per_session'] as num?)?.toDouble();
    final coachType     = _coachData?['coach_type'] as String? ?? '';

    final initials = name.trim().split(' ').take(2)
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .join();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          vGap(10),

          // ── Avatar ─────────────────────────────────────────────
          CircleAvatar(
            backgroundColor: AppColors.teal.withValues(alpha: 0.2),
            radius: 46.r,
            child: Text(initials,
                style: AppTextStyles.font16WhiteBold.copyWith(
                    color: AppColors.teal, fontSize: 22.sp)),
          ),
          vGap(12),
          Text(name, style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 18.sp)),
          vGap(4),
          Text(specialization,
              style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
          vGap(6),

          // ── Rating ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_rounded, color: Colors.amber, size: 16.r),
              hGap(4),
              Text(rating > 0 ? rating.toStringAsFixed(1) : 'No ratings',
                  style: AppTextStyles.font14GreyRegular.copyWith(
                      color: Colors.amber, fontWeight: FontWeight.w600)),
              if (reviewsCount > 0) ...[
                hGap(4),
                Text('($reviewsCount reviews)',
                    style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
              ],
            ],
          ),

          vGap(20),

          // ── Specialization card ─────────────────────────────────
          _SectionCard(children: [
            _InfoRow(Icons.work_outline, s.experience,
                specialization.isNotEmpty ? specialization : 'N/A'),
            if (coachType.isNotEmpty)
              _InfoRow(Icons.sports_gymnastics_outlined, 'Coaching Type',
                  _typeLabel(coachType)),
            if (price != null)
              _InfoRow(Icons.attach_money_outlined, 'Session Price',
                  '${price.toStringAsFixed(0)} EGP'),
          ]),

          if (bio.isNotEmpty) ...[
            vGap(12),
            _SectionCard(children: [
              Text('Bio', style: AppTextStyles.font14GreyRegular.copyWith(
                  color: AppColors.teal, fontWeight: FontWeight.w600, fontSize: 11.sp)),
              vGap(4),
              Text(bio,
                  style: AppTextStyles.font14GreyRegular.copyWith(
                      height: 1.5, color: Colors.white70)),
            ]),
          ],

          vGap(12),

          // ── Availability toggle ─────────────────────────────────
          _SectionCard(children: [
            Row(
              children: [
                Icon(Icons.circle,
                    size: 8.r,
                    color: _available ? AppColors.emerald : AppColors.grey),
                hGap(8),
                Expanded(
                  child: Text(s.show_available_new_members,
                      style: AppTextStyles.font14WhiteRegular),
                ),
                if (_savingAvail)
                  SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.teal),
                  )
                else
                  Switch(
                    value: _available,
                    onChanged: _toggleAvailability,
                    activeThumbColor: AppColors.teal,
                    activeTrackColor: AppColors.teal.withValues(alpha: 0.4),
                  ),
              ],
            ),
          ]),

          vGap(12),

          // ── Settings ────────────────────────────────────────────
          _SectionCard(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.language, color: AppColors.grey, size: 20.r),
              title: Text(s.language_option, style: AppTextStyles.font14WhiteRegular),
              trailing: Text(s.language, style: AppTextStyles.font14GreyRegular),
            ),
            const Divider(color: Colors.white10),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_none,
                  color: AppColors.grey, size: 20.r),
              title: Text(s.notifications, style: AppTextStyles.font14WhiteRegular),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: AppColors.grey, size: 14.r),
            ),
            const Divider(color: Colors.white10),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.security_outlined,
                  color: AppColors.grey, size: 20.r),
              title: Text(s.security, style: AppTextStyles.font14WhiteRegular),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: AppColors.grey, size: 14.r),
            ),
          ]),

          vGap(20),

          // ── Logout ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loggingOut ? null : _logout,
              icon: _loggingOut
                  ? SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.logout, size: 18.r),
              label: Text(_loggingOut ? 'Signing out…' : s.log_out),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                textStyle: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          vGap(20),
        ],
      ),
    );
  }

  String _typeLabel(String t) => switch (t) {
        'training'  => 'Personal Training',
        'nutrition' => 'Nutrition Coaching',
        'both'      => 'Training + Nutrition',
        _           => t,
      };
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: AppDecorations.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Icon(icon, color: AppColors.teal, size: 16.r),
          hGap(10),
          Expanded(child: Text(label, style: AppTextStyles.font14GreyRegular)),
          Text(value,
              style: AppTextStyles.font14WhiteRegular
                  .copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
