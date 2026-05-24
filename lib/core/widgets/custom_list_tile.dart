import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/localization.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const CustomListTile({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: EdgeInsets.all(10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color, size: 25.sp),
        ),
        title: Text(
          title,
          style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 22.sp),
        ),
        subtitle: Text(subTitle, style: AppTextStyles.font14GreyRegular),
        trailing:
            Icon(isArabicLocale(context)? Icons.arrow_back_ios_outlined :Icons.arrow_forward_ios, color: AppColors.grey,)

      ),
    );
  }
}
