import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class NutritionProgressContainer extends StatelessWidget {
  const NutritionProgressContainer({
    super.key,
    required this.title,
    required this.value,
    required this.target,
    this.unit = 'g',
    this.progressColor = Colors.white,
    this.backgroundColor = const Color(0xff2A2F3A),
    required this.icon,
  });

  final String title;
  final double value;
  final double target;
  final String unit;
  final Color progressColor;
  final Color backgroundColor;
  final Icon icon;

  double get progress => (value / target).clamp(0, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: AppDecorations.containerDecoration,
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.font14WhiteRegular),
              icon,
            ],
          ),

          vGap(15),

          /// Value
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${value.toInt()}$unit ',
                  style: AppTextStyles.font16WhiteBold.copyWith(
                    fontSize: 20.sp,
                  ),
                ),
                TextSpan(
                  text: '/ ${target.toInt()}$unit',
                  style: AppTextStyles.font14GreyRegular,
                ),
              ],
            ),
          ),

          vGap(10),

          /// Progress Bar
          LinearProgressIndicator(
            borderRadius: BorderRadius.circular(4),
            value: progress,
            minHeight: 6,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation(progressColor),
          ),
        ],
      ),
    );
  }
}
