import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/enums/login.dart';

import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';

import '../../../../generated/l10n.dart';
import '../../data/auth_repository.dart';
import '../../data/social_auth_service.dart';
import '../../ui/views/survey_view.dart';
import 'member_tabbar_view.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  bool _socialLoading = false;
  String? _socialError;

  Future<void> _handleSocialLogin(
      Future<SocialAuthResult> Function() getCredential) async {
    setState(() {
      _socialLoading = true;
      _socialError = null;
    });

    try {
      final result = await getCredential();
      await AuthRepository.socialLogin(
        provider: result.provider,
        providerId: result.providerId,
        email: result.email,
        name: result.name,
      );

      if (!mounted) return;
      context.go(OnboardingView.routeName);
    } catch (e) {
      if (!mounted) return;
      setState(() => _socialError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _socialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: LinearGradient(
                      colors: [AppColors.emerald, AppColors.blue],
                    ),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/dumbbell.svg',
                    colorFilter: ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                    width: 50,
                  ),
                ),
              ),
              vGap(15),
              Text(s.app_name, style: AppTextStyles.font24GreyBold),
              vGap(10),
              Text(s.app_tagline, style: AppTextStyles.font20GreyRegular),
              vGap(15),
              Container(
                padding: EdgeInsets.all(16),
                decoration: AppDecorations.containerDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(s.welcome_back, style: AppTextStyles.font16WhiteRegular),
                    vGap(5),
                    Text(s.select_role, style: AppTextStyles.font14GreyRegular),
                    vGap(10),
                    CustomTabBar(
                      tabs: [
                        _buildTab(text: s.member, icon: Icons.person_outline),
                        _buildTab(text: s.coach, icon: Icons.sports_gymnastics),
                        _buildTab(text: s.admin, icon: Icons.admin_panel_settings),
                      ],
                    ),
                    vGap(10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: TabBarView(
                        children: [
                          MemberTabBarView(role: LoginRole.member),
                          MemberTabBarView(role: LoginRole.coach),
                          MemberTabBarView(role: LoginRole.admin),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              vGap(20),
              // ── Social login (members only) ──────────────────────
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.grey.withValues(alpha: 0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or continue as member',
                      style: AppTextStyles.font14GreyRegular,
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.grey.withValues(alpha: 0.3))),
                ],
              ),
              vGap(12),
              if (_socialError != null) ...[
                Text(
                  _socialError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                vGap(8),
              ],
              if (_socialLoading)
                const CircularProgressIndicator()
              else
                Column(
                  children: [
                    _SocialButton(
                      label: 'Continue with Google',
                      iconPath: null,
                      fallbackIcon: Icons.g_mobiledata,
                      onTap: () => _handleSocialLogin(
                          SocialAuthService.signInWithGoogle),
                    ),
                    if (Platform.isIOS) ...[
                      vGap(10),
                      _SocialButton(
                        label: 'Sign in with Apple',
                        iconPath: null,
                        fallbackIcon: Icons.apple,
                        onTap: () => _handleSocialLogin(
                            SocialAuthService.signInWithApple),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab({required String text, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), vGap(5), Text(text)],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final String? iconPath;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.iconPath,
    required this.fallbackIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grey.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconPath != null
                ? SvgPicture.asset(iconPath!, width: 20.w, height: 20.h)
                : Icon(fallbackIcon, color: Colors.white, size: 22.sp),
            SizedBox(width: 10.w),
            Text(
              label,
              style: AppTextStyles.font16WhiteRegular.copyWith(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
