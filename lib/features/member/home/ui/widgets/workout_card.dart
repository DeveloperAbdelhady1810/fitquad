import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';

import '../../../../../generated/l10n.dart';


class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.calories,
    required this.exercisesCount,
    required this.onStart,
    this.backgroundColor,
    this.buttonColor,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final String duration;
  final String calories;
  final String exercisesCount;
  final VoidCallback onStart;

  final Color? backgroundColor;
  final Color? buttonColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.containerDecoration.copyWith(
        border: Border(right: BorderSide(color: AppColors.emerald, width: 7)),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.font16WhiteBold),
                  vGap(5),
                  Text(subtitle, style: AppTextStyles.font14GreyRegular),
                ],
              ),
              FaIcon(FontAwesomeIcons.strikethrough, color: AppColors.emerald,)
            ],
          ),

          vGap(15),

          /// Info Row
          Row(
            children: [
              _InfoItem(icon: Icons.timer_outlined, text: duration  , color: AppColors.emerald,),
              hGap(10),
              _InfoItem(icon: Icons.local_fire_department, text: calories , color: AppColors.red,),
              hGap(10),
              _InfoItem(icon: Icons.fitness_center, text: exercisesCount, color: AppColors.blue,),
            ],
          ),

          vGap(15),

          /// Button
        CustomButton(text:s.start_workout, onPressed: onStart,)
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: color),
        hGap(5),
        Text(text, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
