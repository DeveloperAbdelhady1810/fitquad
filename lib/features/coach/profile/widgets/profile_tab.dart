import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';

import '../../../../generated/l10n.dart';

class CoachProfileTab extends StatefulWidget {
  const CoachProfileTab({super.key});

  @override
  State<CoachProfileTab> createState() => _CoachProfileTabState();
}

class _CoachProfileTabState extends State<CoachProfileTab> {
  bool isShown = false;
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final List list = ['Fat Loss', 'Bodybuilding'];
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: AppColors.grey,
              radius: 50.r,
              child: Icon(Icons.person, size: 50.sp),
            ),

            vGap(15),
            Text('Ahmed Mohamed', style: AppTextStyles.font16WhiteBold),
            Text('Senior Coach', style: AppTextStyles.font14GreyRegular),
            vGap(10),
            CustomButton(
              text: s.edit_profile,
              onPressed: () {},
              color: AppColors.secondary,
              width: 100.w,
            ),
            vGap(20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                s.experience_specialization.toUpperCase(),
                style: AppTextStyles.font16GreyRegular,
              ),
            ),
            vGap(10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: AppDecorations.containerDecoration,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.experience,
                        style: AppTextStyles.font14GreyRegular,
                      ),
                      Text('5 Years', style: AppTextStyles.font14WhiteRegular),
                    ],
                  ),
                  const Divider(),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      s.specialties,
                      style: AppTextStyles.font14GreyRegular,
                    ),
                  ),
                  Row(
                    children: list
                        .map(
                          (e) => Container(
                            decoration: AppDecorations.containerDecoration,
                            padding: EdgeInsets.all(7),
                            margin: EdgeInsets.all(5),
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
            vGap(10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                s.availability.toUpperCase(),
                style: AppTextStyles.font16GreyRegular,
              ),
            ),
            vGap(10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: AppDecorations.containerDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.show_available_new_members,
                    style: AppTextStyles.font16GreyRegular,
                  ),
                  Switch(
                    activeThumbColor: AppColors.grey,
                    value: isShown,
                    onChanged: (value) {
                      setState(() {
                        isShown = !isShown;
                      });
                    },
                  ),
                ],
              ),
            ),
            vGap(10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                s.settings.toUpperCase(),
                style: AppTextStyles.font16GreyRegular,
              ),
            ),
            vGap(10),
            Container(
              padding: EdgeInsets.all(10),
              decoration: AppDecorations.containerDecoration,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.language, color: AppColors.grey),
                    title: Text(
                      s.language_option,
                      style: AppTextStyles.font14WhiteRegular,
                    ),
                    trailing: Text(
                      s.language,
                      style: AppTextStyles.font14GreyRegular,
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.notifications_none,
                      color: AppColors.grey,
                    ),
                    title: Text(
                      s.notifications,
                      style: AppTextStyles.font14WhiteRegular,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.security_sharp, color: AppColors.grey),
                    title: Text(
                      s.security,
                      style: AppTextStyles.font14WhiteRegular,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            vGap(10),
            CustomButton(
              iconBeforeText: true,
              iconData: Icons.logout,
              text: s.log_out,
              onPressed: () {},
              color: AppColors.red,
            ),
          ],
        ),
      ),
    );
  }
}
