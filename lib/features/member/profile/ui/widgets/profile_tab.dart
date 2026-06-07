import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/ui/views/login_view.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/inbody/ui/inbody_screen.dart';
import 'package:gym_app/features/member/notifications/notification_preferences_screen.dart';
import 'package:gym_app/features/member/qr/qr_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gym_app/features/member/invitations/ui/invitations_screen.dart';

import '../../../../../core/cubit/language/language_cubit.dart';
import '../../../../../core/cubit/theme/theme_cubit.dart';
import '../../../../../core/theme/theme_config.dart';
import '../../../../../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploadingAvatar = false;
  bool _loggingOut      = false;
  List<Map<String, dynamic>> _checkIns = [];
  bool _checkInsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    setState(() => _checkInsLoading = true);
    try {
      final res = await ApiClient.get('/member/check-ins');
      final raw = (res['data'] as Map?)?['data'] ?? res['data'] ?? [];
      if (!mounted) return;
      setState(() {
        _checkIns = (raw as List).cast<Map<String, dynamic>>().take(20).toList();
        _checkInsLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checkInsLoading = false);
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (picked == null || !mounted) return;

    setState(() => _uploadingAvatar = true);
    try {
      final res = await ApiClient.uploadMultipart(
        '/auth/profile/avatar',
        File(picked.path),
        fileField: 'avatar',
      );
      final url = res['data']?['avatar_url'] as String?;
      if (url != null && mounted) {
        // Reload to pick up the new avatar_url from the server
        context.read<MemberCubit>().loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
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
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: BlocBuilder<MemberCubit, MemberState>(
          builder: (context, state) {
            final name      = state is MemberLoaded ? (state.member.name ?? 'Member') : '...';
            final memberType = state is MemberLoaded ? (state.member.type?.name ?? 'Member') : 'Member';
            final isActive   = state is MemberLoaded && state.member.status?.name == 'active';
            final avatarUrl  = state is MemberLoaded ? state.member.avatarUrl : null;
            final initials   = name.trim().split(' ').take(2)
                .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_ios, color: AppColors.grey, size: 20.r),
                    ),
                  ),

                  // ── Avatar ──────────────────────────────────────────
                  GestureDetector(
                    onTap: _uploadingAvatar ? null : _pickAvatar,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46.r,
                          backgroundColor: AppColors.teal.withValues(alpha: 0.2),
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: _uploadingAvatar
                              ? const CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2)
                              : avatarUrl == null
                                  ? Text(initials,
                                      style: AppTextStyles.font16WhiteBold.copyWith(
                                          color: AppColors.teal, fontSize: 22.sp))
                                  : null,
                        ),
                        // Camera badge
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _uploadingAvatar ? null : _pickAvatar,
                            child: Container(
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: AppColors.teal,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 13.r),
                            ),
                          ),
                        ),
                        // QR badge
                        Positioned(
                          bottom: 2,
                          left: 2,
                          child: GestureDetector(
                            onTap: () => showQrSheet(context),
                            child: Container(
                              padding: EdgeInsets.all(5.r),
                              decoration: BoxDecoration(
                                color: AppColors.emerald,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primary, width: 2),
                              ),
                              child: Icon(Icons.qr_code_2, color: Colors.white, size: 13.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  vGap(12),
                  Text(name, style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 18.sp)),
                  vGap(4),
                  Text('Tap avatar to change photo',
                      style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
                  vGap(8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFF072518),
                      border: Border.all(color: isActive ? AppColors.emerald : AppColors.grey),
                    ),
                    child: Text(
                      isActive ? 'Pro Member' : memberType,
                      style: AppTextStyles.font14GreyRegular.copyWith(
                          color: isActive ? AppColors.emerald : AppColors.grey),
                    ),
                  ),
                  vGap(20),

                  // ── Account section ─────────────────────────────────
                  _SectionHeader(s.account),
                  vGap(8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: AppDecorations.containerDecoration,
                    child: Column(
                      children: [
                        _Tile(
                          icon: Icons.person_outline,
                          title: s.personal_details,
                          onTap: () => _showPersonalDetails(context, state),
                        ),
                        const Divider(),
                        _Tile(
                          icon: Icons.account_balance_wallet_outlined,
                          title: s.membership_billing,
                          onTap: () => _showMembershipInfo(context, state),
                        ),
                        const Divider(),
                        _Tile(
                          icon: Icons.history,
                          title: s.visit_history,
                          onTap: () => _showVisitHistory(context),
                        ),
                        const Divider(),
                        _Tile(
                          icon: Icons.monitor_weight_outlined,
                          iconColor: AppColors.teal,
                          title: 'InBody Results',
                          subtitle: 'Track body composition',
                          onTap: () => context.push(InBodyScreen.routeName),
                        ),
                      ],
                    ),
                  ),
                  vGap(15),

                  // ── Settings section ────────────────────────────────
                  _SectionHeader(s.settings),
                  vGap(8),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: AppDecorations.containerDecoration,
                    child: Column(
                      children: [
                        _Tile(
                          icon: Icons.notifications_outlined,
                          title: s.notifications,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen()),
                          ),
                        ),
                        const Divider(),
                        BlocBuilder<LanguageCubit, LanguageState>(
                          builder: (context, langState) {
                            final isEn = !(context.read<LanguageCubit>().isArabic ?? false);
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.language, color: AppColors.grey),
                              title: Text(s.language, style: AppTextStyles.font16WhiteRegular),
                              subtitle: Text(isEn ? 'English' : 'العربية',
                                  style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
                              trailing: Switch(
                                value: isEn,
                                activeThumbColor: AppColors.teal,
                                activeTrackColor: AppColors.teal.withValues(alpha: 0.3),
                                onChanged: (_) => context.read<LanguageCubit>().toggleLanguage(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        _Tile(
                          icon: Icons.security_outlined,
                          title: 'Security',
                          onTap: () => _showChangePassword(context),
                        ),
                        const Divider(),
                        _ThemeTile(),
                      ],
                    ),
                  ),
                  vGap(20),

                  // ── Loyalty Card ────────────────────────────────────
                  if (state is MemberLoaded) ...[
                    _LoyaltyCard(points: state.member.loyaltyPoints),
                    vGap(14),
                  ],

                  // ── Referral Card ───────────────────────────────────
                  if (state is MemberLoaded) ...[
                    _ReferralCard(
                      code: state.member.referralCode,
                      memberName: state.member.name ?? 'You',
                      discountCredits: state.member.referralDiscountCredits,
                    ),
                    vGap(20),
                  ],

                  // ── Sign Out ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loggingOut ? null : _logout,
                      icon: _loggingOut
                          ? SizedBox(width: 16.r, height: 16.r,
                              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Icon(Icons.logout, size: 18.r),
                      label: Text(_loggingOut ? 'Signing out…' : s.log_out),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 13.h),
                        textStyle: AppTextStyles.font14WhiteRegular.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  vGap(24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Personal Details sheet ─────────────────────────────────────────────────

  void _showPersonalDetails(BuildContext context, MemberState state) {
    final member   = state is MemberLoaded ? state.member : null;
    final nameCtrl = TextEditingController(text: member?.name ?? '');
    final wtCtrl   = TextEditingController(text: member?.weight?.toStringAsFixed(1) ?? '');
    String selectedGoal = member?.type?.name ?? 'fit';
    bool saving = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Personal Details', style: AppTextStyles.font16WhiteBold),
              vGap(20),
              _SheetField(label: 'Name', ctrl: nameCtrl),
              vGap(12),
              _SheetField(
                  label: 'Weight (kg)',
                  ctrl: wtCtrl,
                  keyboardType: TextInputType.number),
              vGap(12),
              Text('Goal', style: AppTextStyles.font14GreyRegular),
              vGap(6),
              DropdownButtonFormField<String>(
                initialValue: selectedGoal,
                dropdownColor: AppColors.primary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.primary,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                ),
                style: AppTextStyles.font14WhiteRegular,
                items: const [
                  DropdownMenuItem(value: 'loss', child: Text('Weight Loss')),
                  DropdownMenuItem(value: 'fit',  child: Text('Stay Fit')),
                  DropdownMenuItem(value: 'low',  child: Text('Low Intensity')),
                  DropdownMenuItem(value: 'neww', child: Text('New to Gym')),
                ],
                onChanged: (v) { if (v != null) setSheetState(() => selectedGoal = v); },
              ),
              vGap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                  ),
                  onPressed: saving ? null : () async {
                    setSheetState(() => saving = true);
                    try {
                      await ApiClient.put('/auth/profile', {
                        'name': nameCtrl.text.trim(),
                        'goal': selectedGoal,
                        if (wtCtrl.text.isNotEmpty)
                          'current_weight': double.tryParse(wtCtrl.text) ?? 0,
                      });
                      if (mounted) {
                        Navigator.pop(ctx);
                        context.read<MemberCubit>().loadAll();
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Save failed: $e'),
                          backgroundColor: AppColors.red,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    } finally {
                      if (ctx.mounted) setSheetState(() => saving = false);
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Membership info sheet ──────────────────────────────────────────────────

  void _showMembershipInfo(BuildContext context, MemberState state) {
    final status = state is MemberLoaded ? (state.member.status?.name ?? 'Unknown') : 'Unknown';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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

  // ── Visit History sheet ─────────────────────────────────────────────────────

  void _showVisitHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 0),
              child: Row(
                children: [
                  Text('Visit History', style: AppTextStyles.font16WhiteBold),
                  const Spacer(),
                  Text('${_checkIns.length} visits',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: AppColors.teal)),
                ],
              ),
            ),
            vGap(12),
            Expanded(
              child: _checkInsLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
                  : _checkIns.isEmpty
                      ? Center(child: Text('No check-ins yet',
                          style: AppTextStyles.font14GreyRegular))
                      : ListView.separated(
                          controller: ctrl,
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          itemCount: _checkIns.length,
                          separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                          itemBuilder: (_, i) {
                            final ci  = _checkIns[i];
                            final raw = ci['checked_in_at'] as String? ?? '';
                            final dt  = DateTime.tryParse(raw)?.toLocal();
                            final dateStr = dt != null
                                ? '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}'
                                : raw;
                            final branch = (ci['branch'] as Map?)?['name'] as String? ?? 'Gym';
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 18.r,
                                backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                                child: Icon(Icons.fitness_center,
                                    color: AppColors.teal, size: 16.r),
                              ),
                              title: Text(branch,
                                  style: AppTextStyles.font14WhiteRegular),
                              subtitle: Text(dateStr,
                                  style: AppTextStyles.font14GreyRegular
                                      .copyWith(fontSize: 11.sp)),
                              trailing: Text('+${ci['xp_gained'] ?? 10} XP',
                                  style: AppTextStyles.font14GreyRegular
                                      .copyWith(color: AppColors.emerald,
                                          fontWeight: FontWeight.w600)),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Change password sheet ───────────────────────────────────────────────────

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool saving       = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: AppTextStyles.font16WhiteBold),
              vGap(20),
              _SheetField(label: 'Current password', ctrl: currentCtrl, obscure: true),
              vGap(12),
              _SheetField(label: 'New password', ctrl: newCtrl, obscure: true),
              vGap(12),
              _SheetField(label: 'Confirm new password', ctrl: confirmCtrl, obscure: true),
              vGap(20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                  ),
                  onPressed: saving ? null : () async {
                    if (newCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Passwords do not match'),
                        behavior: SnackBarBehavior.floating,
                      ));
                      return;
                    }
                    setSheetState(() => saving = true);
                    try {
                      await ApiClient.put('/auth/profile', {
                        'current_password': currentCtrl.text,
                        'password': newCtrl.text,
                        'password_confirmation': confirmCtrl.text,
                      });
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Password changed successfully'),
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    } catch (e) {
                      if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString().replaceFirst('Exception: ', '')),
                        backgroundColor: AppColors.red,
                        behavior: SnackBarBehavior.floating,
                      ));
                    } finally {
                      if (ctx.mounted) setSheetState(() => saving = false);
                    }
                  },
                  child: saving
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Update Password'),
                ),
              ),
              vGap(8),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text, style: AppTextStyles.font16GreyRegular),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: iconColor ?? AppColors.grey),
    title: Text(title, style: AppTextStyles.font16WhiteRegular),
    subtitle: subtitle != null
        ? Text(subtitle!, style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp))
        : null,
    trailing: Icon(Icons.arrow_forward_ios_outlined, color: AppColors.grey),
    onTap: onTap,
  );
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool obscure;
  final TextInputType keyboardType;

  const _SheetField({
    required this.label,
    required this.ctrl,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.font14GreyRegular),
      vGap(6),
      TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: AppTextStyles.font14WhiteRegular,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.primary,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        ),
      ),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
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
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFF2ECC71).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r, height: 48.r,
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stars_rounded, color: const Color(0xFF2ECC71), size: 26.r),
          ),
          hGap(14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Loyalty Points', style: AppTextStyles.font14GreyRegular.copyWith(
                  color: Colors.white70, fontSize: 11.sp)),
              vGap(2),
              Text('$points pts', style: AppTextStyles.font16WhiteBold.copyWith(
                  color: const Color(0xFF2ECC71), fontSize: 20.sp)),
              vGap(2),
              Text('= $credit EGP store credit',
                  style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('1 EGP spent', style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp)),
            Text('= 1 point', style: AppTextStyles.font14GreyRegular.copyWith(
                fontSize: 10.sp, color: const Color(0xFF2ECC71))),
          ]),
        ],
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeConfig>(
      builder: (context, current) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.palette_outlined, color: current.accent),
        title: Text('App Theme', style: AppTextStyles.font16WhiteRegular),
        subtitle: Text('${current.emoji} ${current.name}',
            style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
        trailing: Icon(Icons.arrow_forward_ios_outlined, color: AppColors.grey, size: 14),
        onTap: () => _showThemePicker(context, current),
      ),
    );
  }

  void _showThemePicker(BuildContext context, ThemeConfig current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Theme', style: AppTextStyles.font16WhiteBold),
            vGap(20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: ThemeConfig.presets.map((theme) {
                final selected = theme.id == current.id;
                return GestureDetector(
                  onTap: () {
                    context.read<ThemeCubit>().setTheme(theme);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.gradientStart.withValues(alpha: selected ? 0.4 : 0.15),
                          theme.gradientEnd.withValues(alpha: selected ? 0.25 : 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? theme.accent : theme.accent.withValues(alpha: 0.3),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(theme.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(theme.name,
                                style: AppTextStyles.font14WhiteRegular
                                    .copyWith(color: theme.accent, fontWeight: FontWeight.w600)),
                            if (selected)
                              Text('Active',
                                  style: AppTextStyles.font14GreyRegular
                                      .copyWith(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            vGap(8),
          ],
        ),
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final String? code;
  final String memberName;
  final int discountCredits;
  const _ReferralCard({
    required this.code,
    required this.memberName,
    this.discountCredits = 0,
  });

  @override
  Widget build(BuildContext context) {
    final displayCode = code ?? '...';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1B3A6B), Color(0xFF0D2545)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.card_giftcard_outlined, color: AppColors.blue, size: 22.r),
          hGap(8),
          Text('Invite Friends & Earn', style: AppTextStyles.font16WhiteBold),
        ]),
        vGap(8),
        Text('Share your code. When a friend signs up with it, you instantly earn a 5% platform-fee discount on your next 2 online purchases!',
            style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12.sp, height: 1.4)),
        if (discountCredits > 0) ...[
          vGap(10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              Icon(Icons.local_offer_outlined, color: AppColors.emerald, size: 16.r),
              hGap(8),
              Expanded(
                child: Text(
                  'You have $discountCredits fee-free purchase${discountCredits == 1 ? '' : 's'} waiting — applied automatically at checkout.',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(color: AppColors.emerald, fontSize: 11.sp, height: 1.3),
                ),
              ),
            ]),
          ),
        ],
        vGap(14),
        Row(children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.blue.withValues(alpha: 0.4)),
              ),
              child: Text(displayCode,
                  style: AppTextStyles.font16WhiteBold.copyWith(
                      letterSpacing: 3, color: AppColors.blue),
                  textAlign: TextAlign.center),
            ),
          ),
          hGap(10),
          GestureDetector(
            onTap: () {
              if (code == null) return;
              Clipboard.setData(ClipboardData(text: code!));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Code copied!'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 1),
              ));
            },
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r)),
              child: Icon(Icons.copy_outlined, color: AppColors.blue, size: 20.r),
            ),
          ),
        ]),
        vGap(12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            icon: Icon(Icons.share_outlined, size: 18.r),
            label: Text('Share Invite Link', style: AppTextStyles.font14WhiteRegular),
            onPressed: () {
              if (code == null) return;
              final text =
                  'Join me on FitQuad! Use my code $code when signing up. 💪';
              Share.share(text, subject: 'Join FitQuad!');
            },
          ),
        ),
        vGap(8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side:
                  BorderSide(color: AppColors.blue.withValues(alpha: 0.5)),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InvitationsScreen()),
                ),
            icon:
                Icon(Icons.people_outline, color: AppColors.blue, size: 18.r),
            label: Text('View My Invites',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.blue)),
          ),
        ),
      ]),
    );
  }
}
