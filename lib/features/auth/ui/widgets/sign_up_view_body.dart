import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gym_app/core/enums/login.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';

import '../../../../generated/l10n.dart';
import 'member_tabbar_view.dart';

class SignUpViewBody extends StatelessWidget {
  const SignUpViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DefaultTabController(
      length: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  CustomTabBar(tabs: [_buildTab(text: s.member, icon: Icons.person_outline),
                    _buildTab(text: s.coach, icon: Icons.sports_gymnastics),],),
                  vGap(10),

                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: TabBarView(
                      children: [

                        MemberTabBarView(role: LoginRole.member, isSignUp: true,),
                        MemberTabBarView(role: LoginRole.coach, isSignUp: true),
                        MemberTabBarView(role: LoginRole.admin, isSignUp: true),
                      ],

                    ),
                  ),
                ],
              ),
            ),
          ],
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
