import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/helpers.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/features/coach/home/ui/widgets/overview_tab_bar_view.dart';
import 'package:gym_app/features/coach/home/ui/widgets/nutrition_tab_bar_view.dart';
import 'package:gym_app/features/coach/home/ui/widgets/training_tab_bar_view.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../generated/l10n.dart';
import '../../../../member/data/models/member_model.dart';
import 'chat_tab_bar_view.dart';
import 'inbody_tab_bar_view.dart';

class MemberProfileScreen extends StatelessWidget {
  final MemberModel member;

  const MemberProfileScreen({super.key, required this.member});
  static const String routeName = '/member-profile';

  @override
  Widget build(BuildContext context) {
    final List<String> list = ['fat loss', 'strength', 'injury'];

    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.white),
        backgroundColor: AppColors.primary,
        title: Text(s.member_profile, style: AppTextStyles.font14WhiteRegular),
      ),
      backgroundColor: AppColors.primary,
      body: DefaultTabController(
        length: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: Text(
                  Helpers.getInitials(member.name ?? ''),
                  style: AppTextStyles.font14WhiteRegular,
                ),
              ),
              title: Text(
                member.name ?? '',
                style: AppTextStyles.font16WhiteBold,
              ),
              subtitle: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        member.age.toString(),
                        style: AppTextStyles.font14WhiteRegular,
                      ),
                      hGap(10),
                      Text('Male', style: AppTextStyles.font14WhiteRegular),
                      hGap(10),
                      Text(
                        'Intermediate',
                        style: AppTextStyles.font14WhiteRegular,
                      ),
                    ],
                  ),
                  Row(
                    children: list
                        .map(
                          (e) => Container(
                            decoration: AppDecorations.containerDecoration,
                            padding: EdgeInsets.all(10),
                            child: Text(
                              e,
                              style: AppTextStyles.font14WhiteRegular,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            CustomTabBar(
              isScrollable: true,

              tabs: [
                Tab(text: s.overview),
                Tab(text: s.training),
                Tab(text: s.nutrition),
                Tab(text: s.inbody),
                Tab(text: s.messages),
              ],
            ),

            Expanded(
              child: TabBarView(
                children: [
                  OverviewTabBarView(member: member),
                  TrainingTabBarViewScreen(),
                  NutritionTabBarView(),
                  InBodyTabBarView(),
                  DirectChatScreen(member: member,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
