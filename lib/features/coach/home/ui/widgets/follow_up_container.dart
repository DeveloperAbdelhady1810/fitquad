import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../../../../generated/l10n.dart';

class FollowUpContainer extends StatelessWidget {
  final String name;
  final void Function()? onTap;
  const FollowUpContainer({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final s= S.of(context);
    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: EdgeInsets.all(10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown,
          child: Text(getInitials(name), style: AppTextStyles.font16WhiteBold),
        ),
        title: Text(name, style: AppTextStyles.font16WhiteRegular),
        subtitle: Container(
          padding: EdgeInsets.all(5),
          decoration: AppDecorations.containerDecoration.copyWith(
            color: AppColors.red.withValues(alpha: 0.2),
          ),
          child: Text(
            'data',
            style: AppTextStyles.font14GreyRegular.copyWith(
              color: AppColors.red,
            ),
          ),
        ),
        trailing: Container(
          decoration: AppDecorations.containerDecoration,
          padding: EdgeInsets.all(5),
          child: Text(s.open, style: AppTextStyles.font14WhiteRegular),
        ),
        onTap: onTap
      ),
    );
  }

  String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return fullName[0];
  }
}
