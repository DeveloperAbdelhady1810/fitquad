import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:gym_app/features/member/notifications/notification_preferences_screen.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/cubit/language/language_cubit.dart';
import '../../../../generated/l10n.dart';

class CoachProfileTab extends StatefulWidget {
  const CoachProfileTab({super.key});

  @override
  State<CoachProfileTab> createState() => _CoachProfileTabState();
}

class _CoachProfileTabState extends State<CoachProfileTab> {
  Map<String, dynamic>? _coachData;
  bool _loading         = true;
  bool _available       = true;
  bool _savingAvail     = false;
  bool _uploadingAvatar = false;
  bool _loggingOut      = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res   = await ApiClient.get('/auth/me');
      final user  = res['data'] as Map<String, dynamic>? ?? {};
      final coach = user['coach'] as Map<String, dynamic>? ?? {};
      if (!mounted) return;
      setState(() {
        _coachData = {...user, ...coach};
        _available = coach['is_available'] as bool? ?? true;
        _loading   = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    setState(() { _available = value; _savingAvail = true; });
    try {
      await ApiClient.put('/auth/profile', {'is_available': value});
    } catch (_) {
      if (mounted) setState(() => _available = !value);
    } finally {
      if (mounted) setState(() => _savingAvail = false);
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
        setState(() => _coachData = {...?_coachData, 'avatar_url': url});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Upload failed: ${e.toString().replaceFirst('Exception: ', '')}'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try { await AuthRepository.logout(); } catch (_) {}
    if (mounted) context.go(LoginView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    final name           = _coachData?['name']           as String? ?? 'Coach';
    final specialization = _coachData?['specialization']  as String? ?? 'Personal Trainer';
    final bio            = _coachData?['bio']             as String? ?? '';
    final rating         = (_coachData?['rating']         as num?)?.toDouble() ?? 0.0;
    final reviewsCount   = _coachData?['reviews_count']   as int? ?? 0;
    final price          = (_coachData?['price_per_session'] as num?)?.toDouble();
    final coachType      = _coachData?['coach_type']      as String? ?? '';
    final avatarUrl      = _coachData?['avatar_url']      as String?;

    final initials = name.trim().split(' ').take(2)
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '').join();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          vGap(10),

          // ── Avatar ─────────────────────────────────────────────
          GestureDetector(
            onTap: _uploadingAvatar ? null : _pickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46.r,
                  backgroundColor: AppColors.teal.withValues(alpha: 0.2),
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: _uploadingAvatar
                      ? const CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2)
                      : avatarUrl == null
                          ? Text(initials,
                              style: AppTextStyles.font16WhiteBold
                                  .copyWith(color: AppColors.teal, fontSize: 22.sp))
                          : null,
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
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
              ],
            ),
          ),
          vGap(8),
          Text('Tap to change photo',
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
          vGap(8),
          Text(name, style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 18.sp)),
          vGap(4),
          Text(specialization,
              style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.teal)),
          vGap(6),

          // ── Rating ─────────────────────────────────────────────
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
          ]),
          vGap(16),

          // ── Profile info card ───────────────────────────────────
          _SectionCard(children: [
            _InfoRow(Icons.work_outline, s.experience,
                specialization.isNotEmpty ? specialization : 'N/A'),
            if (coachType.isNotEmpty)
              _InfoRow(Icons.sports_gymnastics_outlined, 'Coaching Type', _typeLabel(coachType)),
            if (price != null)
              _InfoRow(Icons.attach_money_outlined, 'Session Price',
                  '${price.toStringAsFixed(0)} EGP'),
          ]),

          if (bio.isNotEmpty) ...[
            vGap(12),
            _SectionCard(children: [
              Text('Bio',
                  style: AppTextStyles.font14GreyRegular.copyWith(
                      color: AppColors.teal, fontWeight: FontWeight.w600, fontSize: 11.sp)),
              vGap(4),
              Text(bio,
                  style: AppTextStyles.font14GreyRegular.copyWith(height: 1.5, color: Colors.white70)),
            ]),
          ],
          vGap(12),

          // ── Edit profile button ──────────────────────────────────
          _SectionCard(children: [
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.edit_outlined, color: AppColors.teal, size: 20.r),
              title: Text('Edit Profile', style: AppTextStyles.font14WhiteRegular),
              trailing: Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14.r),
              onTap: () => _showEditProfile(context),
            ),
          ]),
          vGap(12),

          // ── Availability toggle ─────────────────────────────────
          _SectionCard(children: [
            Row(children: [
              Icon(Icons.circle, size: 8.r,
                  color: _available ? AppColors.emerald : AppColors.grey),
              hGap(8),
              Expanded(child: Text(s.show_available_new_members,
                  style: AppTextStyles.font14WhiteRegular)),
              if (_savingAvail)
                SizedBox(width: 20.r, height: 20.r,
                    child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal))
              else
                Switch(
                  value: _available,
                  onChanged: _toggleAvailability,
                  activeThumbColor: AppColors.teal,
                  activeTrackColor: AppColors.teal.withValues(alpha: 0.4),
                ),
            ]),
          ]),
          vGap(12),

          // ── Settings ────────────────────────────────────────────
          _SectionCard(children: [
            ListTile(
              dense: true, contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.notifications_none, color: AppColors.grey, size: 20.r),
              title: Text(s.notifications, style: AppTextStyles.font14WhiteRegular),
              trailing: Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14.r),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen())),
            ),
            const Divider(color: Colors.white10),
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, langState) {
                final isEn = !(context.read<LanguageCubit>().isArabic ?? false);
                return ListTile(
                  dense: true, contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.language, color: AppColors.grey, size: 20.r),
                  title: Text(s.language_option, style: AppTextStyles.font14WhiteRegular),
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
            const Divider(color: Colors.white10),
            ListTile(
              dense: true, contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.security_outlined, color: AppColors.grey, size: 20.r),
              title: Text(s.security, style: AppTextStyles.font14WhiteRegular),
              trailing: Icon(Icons.arrow_forward_ios, color: AppColors.grey, size: 14.r),
              onTap: () => _showChangePassword(context),
            ),
          ]),
          vGap(20),

          // ── Logout ──────────────────────────────────────────────
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
          vGap(20),
        ],
      ),
    );
  }

  // ── Edit Profile sheet ──────────────────────────────────────────────────────

  void _showEditProfile(BuildContext context) {
    final nameCtrl  = TextEditingController(text: _coachData?['name'] as String? ?? '');
    final specCtrl  = TextEditingController(text: _coachData?['specialization'] as String? ?? '');
    final bioCtrl   = TextEditingController(text: _coachData?['bio'] as String? ?? '');
    final priceCtrl = TextEditingController(
        text: (_coachData?['price_per_session'] as num?)?.toStringAsFixed(0) ?? '');
    String coachType = _coachData?['coach_type'] as String? ?? 'training';
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile', style: AppTextStyles.font16WhiteBold),
                vGap(16),
                _SheetField(label: 'Name', ctrl: nameCtrl),
                vGap(12),
                _SheetField(label: 'Specialization', ctrl: specCtrl),
                vGap(12),
                _SheetField(label: 'Bio', ctrl: bioCtrl, maxLines: 4),
                vGap(12),
                _SheetField(
                    label: 'Price per session (EGP)',
                    ctrl: priceCtrl,
                    keyboardType: TextInputType.number),
                vGap(12),
                Text('Coaching Type', style: AppTextStyles.font14GreyRegular),
                vGap(6),
                DropdownButtonFormField<String>(
                  initialValue: coachType,
                  dropdownColor: AppColors.primary,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.primary,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  ),
                  style: AppTextStyles.font14WhiteRegular,
                  items: const [
                    DropdownMenuItem(value: 'training',  child: Text('Personal Training')),
                    DropdownMenuItem(value: 'nutrition', child: Text('Nutrition Coaching')),
                    DropdownMenuItem(value: 'both',      child: Text('Training + Nutrition')),
                  ],
                  onChanged: (v) { if (v != null) setSheetState(() => coachType = v); },
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
                          'name':             nameCtrl.text.trim(),
                          'specialization':   specCtrl.text.trim(),
                          'bio':              bioCtrl.text.trim(),
                          'coach_type':       coachType,
                          if (priceCtrl.text.isNotEmpty)
                            'price_per_session': double.tryParse(priceCtrl.text) ?? 0,
                        });
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          _load(); // refresh local state
                        }
                      } catch (e) {
                        if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Save failed: $e'),
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
                        : const Text('Save'),
                  ),
                ),
                vGap(8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Change password sheet ───────────────────────────────────────────────────

  void _showChangePassword(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
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
              Text('Change Password', style: AppTextStyles.font16WhiteBold),
              vGap(16),
              _SheetField(label: 'Current password', ctrl: currentCtrl, obscure: true),
              vGap(12),
              _SheetField(label: 'New password',     ctrl: newCtrl,     obscure: true),
              vGap(12),
              _SheetField(label: 'Confirm password', ctrl: confirmCtrl, obscure: true),
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
                        'current_password':      currentCtrl.text,
                        'password':              newCtrl.text,
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

  String _typeLabel(String t) => switch (t) {
        'training'  => 'Personal Training',
        'nutrition' => 'Nutrition Coaching',
        'both'      => 'Training + Nutrition',
        _           => t,
      };
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(14.r),
    decoration: AppDecorations.containerDecoration,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: 5.h),
    child: Row(children: [
      Icon(icon, color: AppColors.teal, size: 16.r),
      hGap(10),
      Expanded(child: Text(label, style: AppTextStyles.font14GreyRegular)),
      Text(value, style: AppTextStyles.font14WhiteRegular.copyWith(fontWeight: FontWeight.w500)),
    ]),
  );
}

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final bool obscure;
  final int maxLines;
  final TextInputType keyboardType;

  const _SheetField({
    required this.label,
    required this.ctrl,
    this.obscure    = false,
    this.maxLines   = 1,
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
        maxLines: obscure ? 1 : maxLines,
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
