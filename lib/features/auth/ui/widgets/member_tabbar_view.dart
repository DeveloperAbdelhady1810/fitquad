import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/enums/login.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/features/admin/ui/views/admin_view.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/ui/views/login_view.dart';
import 'package:gym_app/features/auth/ui/views/sign_up_view.dart';
import 'package:gym_app/features/auth/ui/views/survey_view.dart';
import 'package:gym_app/features/coach/home/ui/views/coach_bottom_nav_bar_view.dart';
import 'package:gym_app/features/coach/setup/coach_setup_screen.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_feild.dart';
import '../../../../generated/l10n.dart';

class MemberTabBarView extends StatefulWidget {
  final LoginRole role;
  final bool isSignUp;

  const MemberTabBarView({
    super.key,
    required this.role,
    this.isSignUp = false,
  });

  @override
  State<MemberTabBarView> createState() => _MemberTabBarViewState();
}

class _MemberTabBarViewState extends State<MemberTabBarView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isSignUp) {
      _tryAutoFillInviteCode();
    }
  }

  Future<void> _tryAutoFillInviteCode() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      // Auto-fill if clipboard contains an 8-char uppercase alphanumeric string
      if (text.length == 8 && RegExp(r'^[A-Z0-9]+$').hasMatch(text)) {
        if (mounted) {
          setState(() => _inviteCodeController.text = text);
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Text(s.email_or_phone, style: AppTextStyles.font16WhiteBold),
          ),
          vGap(10),
          CustomTextFormField(
            controller: _emailController,
            hintText: 'hello@example.com',
            textInputType: TextInputType.emailAddress,
          ),
          vGap(15),
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Text(s.password, style: AppTextStyles.font16WhiteBold),
          ),
          vGap(10),
          CustomTextFormField(
            controller: _passwordController,
            textInputType: TextInputType.visiblePassword,
            hintText: '••••••••',
          ),
      
          if (widget.isSignUp) ...[
            vGap(15),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Text(s.phone_optional, style: AppTextStyles.font16WhiteBold),
            ),
            vGap(10),
            CustomTextFormField(
              controller: _phoneController,
              textInputType: TextInputType.phone,
              hintText: '+1 (555) 000-0000',
            ),
            vGap(15),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Text('Invite code (optional)',
                  style: AppTextStyles.font16WhiteBold),
            ),
            vGap(4),
            Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Text(
                'Have a friend\'s invite code? Enter it here.',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 12),
              ),
            ),
            vGap(10),
            CustomTextFormField(
              controller: _inviteCodeController,
              textInputType: TextInputType.text,
              hintText: 'e.g. A3B7F2D1',
            ),
          ],
      
          if (_errorMessage != null) ...[
            vGap(10),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
      
          vGap(20),
          _isLoading
              ? const CircularProgressIndicator()
              : CustomButton(
                  text: widget.isSignUp ? s.sign_up : s.login,
                  onPressed: () => _onSubmit(context),
                  iconData: Icons.arrow_forward,
                  color: _buttonColor(),
                ),
      
          vGap(15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.isSignUp ? s.already_have_account : s.no_account,
                style: AppTextStyles.font14GreyRegular,
              ),
              TextButton(
                onPressed: () => widget.isSignUp
                    ? context.go(LoginView.routeName)
                    : context.go(SignUpView.routeName),
                child: Text(
                  widget.isSignUp ? s.login : s.sign_up,
                  style: AppTextStyles.font14GreyRegular,
                ),
              ),
            ],
          ),
          if (widget.role == LoginRole.member) ...[
            vGap(4),
            TextButton.icon(
              onPressed: () => _showMembershipIdDialog(context),
              icon: Icon(Icons.qr_code_scanner, size: 16, color: AppColors.teal),
              label: Text(
                'Already have a gym membership ID?',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: AppColors.teal, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showMembershipIdDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    bool loading = false;
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.qr_code_scanner, color: Color(0xFF00a689), size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Gym Membership ID',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the membership ID provided by your gym. This links your account to your existing membership.',
                style: TextStyle(color: Color(0xFFe8c1bb), fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'e.g. FQ-2024-001234',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF020618),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF00a689)),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00a689)),
              onPressed: loading
                  ? null
                  : () async {
                      final id = ctrl.text.trim();
                      if (id.isEmpty) return;
                      setLocal(() { loading = true; error = null; });
                      try {
                        await ApiClient.put('/auth/profile', {'membership_code': id});
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Membership linked successfully!'),
                              backgroundColor: Color(0xFF00a689),
                            ),
                          );
                        }
                      } catch (e) {
                        setLocal(() {
                          loading = false;
                          error = e.toString().replaceFirst('Exception: ', '');
                        });
                      }
                    },
              child: loading
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Link Membership'),
            ),
          ],
        ),
      ),
    );
  }

  Color _buttonColor() {
    switch (widget.role) {
      case LoginRole.member:
        return AppColors.emerald;
      case LoginRole.coach:
        return AppColors.blue;
      case LoginRole.admin:
        return AppColors.purple;
    }
  }

  Future<void> _onSubmit(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> data;
      if (widget.isSignUp) {
        data = await AuthRepository.register(
          name: email.split('@').first,
          email: email,
          password: password,
          role: widget.role.name == 'admin' ? 'member' : widget.role.name,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          inviteCode: _inviteCodeController.text.trim().isEmpty
              ? null
              : _inviteCodeController.text.trim(),
        );
      } else {
        data = await AuthRepository.login(email: email, password: password);
      }

      if (!context.mounted) return;

      // Role is already saved by AuthRepository.login/register — read it directly from response
      final role = data['user']?['role'] as String? ?? 'member';

      switch (role) {
        case 'coach':
          if (widget.isSignUp) {
            // New coach: ask freelancer vs gym-staff
            context.go(CoachSetupScreen.routeName);
          } else {
            // Returning coach: check if pending gym request
            final profile = data['profile'] as Map<String, dynamic>? ?? {};
            final gymReq  = profile['gym_request'] as Map<String, dynamic>?;
            if (gymReq != null && gymReq['status'] == 'pending') {
              context.go(CoachGymPendingScreen.routeName);
            } else {
              context.go(CoachBottomNavBarView.routeName);
            }
          }
          break;
        case 'admin':
          context.go(AdminView.routeName);
          break;
        default:
          final isOnboarded = data['user']?['member']?['goal'] != null;
          context.go(isOnboarded ? BottomNavBarView.routeName : OnboardingView.routeName);
      }
    } catch (e) {
      final err = e is ApiException ? e.firstError : e.toString();
      setState(() => _errorMessage = err);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
