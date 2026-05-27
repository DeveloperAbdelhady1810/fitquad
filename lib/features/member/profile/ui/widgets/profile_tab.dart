import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/inbody/ui/inbody_screen.dart';
import 'package:gym_app/features/member/notifications/notification_preferences_screen.dart';
import 'package:gym_app/features/member/qr/qr_screen.dart';

import '../../../../../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEnglish = false;
  bool isNotificationsOn = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: BlocBuilder<MemberCubit, MemberState>(
        builder: (context, state) {
          final name = state is MemberLoaded
              ? (state.member.name ?? 'Member')
              : '...';
          final memberType = state is MemberLoaded
              ? (state.member.type?.name ?? 'Member')
              : 'Member';
          final isActive = state is MemberLoaded &&
              state.member.status?.name == 'active';

          return SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button row
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.arrow_back_ios, color: AppColors.grey, size: 20.r),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () => showQrSheet(context),
                  child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44.r,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundColor: AppColors.secondary,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: AppTextStyles.font24GreyBold.copyWith(
                            fontSize: 32.sp,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 24.r,
                        width: 24.r,
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: Icon(
                          Icons.qr_code_2,
                          color: Colors.white,
                          size: 14.r,
                        ),
                      ),
                    ),
                  ],
                ),
                ),
              ),
              vGap(15),
              Text(name, style: AppTextStyles.font16WhiteBold),
              vGap(5),
              Text('Member since 2025', style: AppTextStyles.font14GreyRegular),
              vGap(10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF072518),
                  border: Border.all(
                    color: isActive ? AppColors.emerald : AppColors.grey,
                  ),
                ),
                child: Text(
                  isActive ? 'Pro Member' : memberType,
                  style: AppTextStyles.font14GreyRegular.copyWith(
                    color: isActive ? AppColors.emerald : AppColors.grey,
                  ),
                ),
              ),
              vGap(20),
              Text(s.account, style: AppTextStyles.font16GreyRegular),
              vGap(10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: AppDecorations.containerDecoration,
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.person_outline, color: AppColors.grey),
                      title: Text(
                        s.personal_details,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.grey,
                      ),
                      onTap: () => _showPersonalDetails(context, state),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.grey,
                      ),
                      title: Text(
                        s.membership_billing,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.grey,
                      ),
                      onTap: () => _showMembershipInfo(context, state),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.refresh, color: AppColors.grey),
                      title: Text(
                        s.visit_history,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.grey,
                      ),
                      onTap: () => _showVisitHistory(context),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.monitor_weight_outlined,
                          color: AppColors.teal),
                      title: Text('InBody Results',
                          style: AppTextStyles.font16WhiteRegular),
                      subtitle: Text('Track body composition',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp)),
                      trailing: Icon(Icons.arrow_forward_ios_outlined,
                          color: AppColors.grey),
                      onTap: () => context.push(InBodyScreen.routeName),
                    ),
                  ],
                ),
              ),
              vGap(15),
              Text(s.settings, style: AppTextStyles.font16GreyRegular),
              vGap(10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: AppDecorations.containerDecoration,
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.notifications_outlined, color: AppColors.grey),
                      title: Text(
                        s.notifications,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationPreferencesScreen(),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.language,
                        color: AppColors.grey,
                      ),
                      title: Text(
                        s.language,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Switch(
                        activeThumbColor: AppColors.emerald,
                        value: isEnglish,
                        onChanged: (value) {
                          setState(() => isEnglish = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              vGap(20),

              // ── Loyalty Points Card ────────────────────────────────
              if (state is MemberLoaded) ...[
                _LoyaltyCard(points: state.member.loyaltyPoints),
                vGap(14),
              ],

              // ── Referral Card ──────────────────────────────────────
              if (state is MemberLoaded) ...[
                _ReferralCard(
                  code: state.member.referralCode,
                  memberName: state.member.name ?? 'You',
                ),
                vGap(20),
              ],
            ],
          ),
        );
        },
      ),
      ),
    );
  }

  void _showPersonalDetails(BuildContext context, MemberState state) {
    final name = state is MemberLoaded ? (state.member.name ?? '') : '';
    final weight = state is MemberLoaded ? (state.member.weight?.toString() ?? '') : '';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Details', style: AppTextStyles.font16WhiteBold),
            vGap(20),
            _DetailRow(label: 'Name', value: name.isNotEmpty ? name : '—'),
            _DetailRow(label: 'Weight', value: weight.isNotEmpty ? '$weight kg' : '—'),
            _DetailRow(
              label: 'Goal',
              value: state is MemberLoaded ? (state.member.type?.name ?? '—') : '—',
            ),
            vGap(16),
          ],
        ),
      ),
    );
  }

  void _showMembershipInfo(BuildContext context, MemberState state) {
    final status = state is MemberLoaded ? (state.member.status?.name ?? 'Unknown') : 'Unknown';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Membership & Billing', style: AppTextStyles.font16WhiteBold),
            vGap(20),
            _DetailRow(label: 'Status', value: status.toUpperCase()),
            _DetailRow(label: 'Plan', value: 'Pro Member'),
            _DetailRow(label: 'Renewal', value: 'Contact gym reception'),
            vGap(16),
          ],
        ),
      ),
    );
  }

  void _showVisitHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visit History', style: AppTextStyles.font16WhiteBold),
            vGap(20),
            Text(
              'Your recent gym visits will appear here once check-in data is available.',
              style: AppTextStyles.font14GreyRegular,
            ),
            vGap(16),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.font14GreyRegular),
          Text(value, style: AppTextStyles.font14WhiteRegular),
        ],
      ),
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  final int points;
  const _LoyaltyCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final credit = (points / 10).floor();
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6B4A), Color(0xFF0D3D2B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF2ECC71).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded,
                color: const Color(0xFF2ECC71), size: 26.r),
          ),
          hGap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loyalty Points',
                  style: AppTextStyles.font14GreyRegular.copyWith(
                      color: Colors.white70, fontSize: 11.sp),
                ),
                vGap(2),
                Text(
                  '$points pts',
                  style: AppTextStyles.font16WhiteBold.copyWith(
                      color: const Color(0xFF2ECC71), fontSize: 20.sp),
                ),
                vGap(2),
                Text(
                  '= $credit EGP store credit',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('1 EGP spent',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 10.sp)),
              Text('= 1 point',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 10.sp,
                          color: const Color(0xFF2ECC71))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final String? code;
  final String memberName;

  const _ReferralCard({required this.code, required this.memberName});

  @override
  Widget build(BuildContext context) {
    final displayCode = code ?? 'LOADING';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B3A6B), Color(0xFF0D2545)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard_outlined,
                  color: AppColors.blue, size: 22.r),
              hGap(8),
              Text('Invite Friends & Earn',
                  style: AppTextStyles.font16WhiteBold),
            ],
          ),
          vGap(8),
          Text(
            'Share your code. When a friend subscribes, you both get 1 free month!',
            style: AppTextStyles.font14GreyRegular
                .copyWith(fontSize: 12.sp, height: 1.4),
          ),
          vGap(14),
          // Code chip
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: AppColors.blue.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    code != null ? displayCode : '...',
                    style: AppTextStyles.font16WhiteBold.copyWith(
                      letterSpacing: 3,
                      color: AppColors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              hGap(10),
              GestureDetector(
                onTap: () {
                  if (code == null) return;
                  Clipboard.setData(ClipboardData(text: code!));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Code copied!'),
                    backgroundColor: AppColors.blue,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ));
                },
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.copy_outlined,
                      color: AppColors.blue, size: 20.r),
                ),
              ),
            ],
          ),
          vGap(12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                if (code == null) return;
                final shareText =
                    'Join me on FitQuad! Use my code $code to get 1 free month when you subscribe. 💪';
                Clipboard.setData(ClipboardData(text: shareText));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Share message copied to clipboard!'),
                  backgroundColor: AppColors.blue,
                  behavior: SnackBarBehavior.floating,
                ));
              },
              icon: Icon(Icons.share_outlined, size: 18.r),
              label: Text('Share Invite Link',
                  style: AppTextStyles.font14WhiteRegular),
            ),
          ),
        ],
      ),
    );
  }
}
