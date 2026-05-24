import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTabBar extends StatelessWidget {
  final List<Widget> tabs;
  final bool isSecondary;
  final bool isScrollable;
  final  void Function(int)? onTap;
  const CustomTabBar({super.key, required this.tabs, this.isSecondary=false, this.onTap , this.isScrollable=false});

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color:isSecondary?AppColors.secondary: AppColors.primary,
      ),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      child: TabBar(
        onTap: onTap,
        isScrollable: isScrollable,
        dividerColor: Colors.transparent,
        /// /// /// /// /// /// /// /// ///
        indicatorPadding: EdgeInsets.all(-10),
        unselectedLabelStyle: AppTextStyles.font16WhiteRegular,
        labelStyle: AppTextStyles.font16TealRegular,

        tabAlignment:isScrollable? TabAlignment.center: TabAlignment.fill,
        indicatorSize: TabBarIndicatorSize.tab,
        
        indicator: BoxDecoration(
          color: AppColors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        tabs: tabs,
      ),
    );
  }


}
