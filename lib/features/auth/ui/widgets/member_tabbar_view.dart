import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/enums/login.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/features/admin/ui/views/admin_view.dart';
import 'package:gym_app/features/auth/data/auth_repository.dart';
import 'package:gym_app/features/auth/ui/views/login_view.dart';
import 'package:gym_app/features/auth/ui/views/sign_up_view.dart';
import 'package:gym_app/features/auth/ui/views/survey_view.dart';
import 'package:gym_app/features/coach/home/ui/views/coach_bottom_nav_bar_view.dart';

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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
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
        ],
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
      if (widget.isSignUp) {
        await AuthRepository.register(
          name: email.split('@').first,
          email: email,
          password: password,
          role: widget.role.name == 'admin' ? 'member' : widget.role.name,
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );
      } else {
        await AuthRepository.login(email: email, password: password);
      }

      if (!context.mounted) return;

      // Determine destination from saved token's role
      final userData = await AuthRepository.me();
      final role = userData['role'] as String? ?? 'member';

      if (!context.mounted) return;
      switch (role) {
        case 'coach':
          context.go(CoachBottomNavBarView.routeName);
          break;
        case 'admin':
          context.go(AdminView.routeName);
          break;
        default:
          context.go(OnboardingView.routeName);
      }
    } catch (e) {
      final err = e is ApiException ? e.firstError : e.toString();
      setState(() => _errorMessage = err);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
