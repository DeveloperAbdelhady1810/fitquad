import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/spacing.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.emerald,
    this.width = double.infinity,
    this.textStyle,
    this.height = 50,
    this.radius = 10,
    this.iconData,
    this.iconBeforeText = false,
  });

  final String text;
  final double width;
  final double radius;
  final double? height;
  final void Function()? onPressed;
  final Color? color;
  final TextStyle? textStyle;
  final IconData? iconData;
  final bool iconBeforeText;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(radius),
          ),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child:  Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (iconData != null && iconBeforeText) ...[
                Icon(iconData, color: AppColors.white, size: 25),
                hGap(5),
              ],

              Text(
                text,
                style: textStyle ?? AppTextStyles.font20WhiteRegular,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),

              if (iconData != null && !iconBeforeText) ...[
                hGap(5),
                Icon(iconData, color: AppColors.black, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
