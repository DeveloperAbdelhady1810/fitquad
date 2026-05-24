import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/helpers.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class CoachContainer extends StatelessWidget {
  final String name;
  final String specialization;
  final double rating;
  final int membersCount;
  final int sessionsCount;
  final bool isActive;

  const CoachContainer({
    super.key,
    required this.name,
    required this.specialization,
    this.rating = 0,
    this.membersCount = 0,
    this.sessionsCount = 0,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF190F03),
            child: Text(
              Helpers.getInitials(name),
              style: AppTextStyles.font16WhiteBold,
            ),
          ),
          vGap(5),
          Text(name, style: AppTextStyles.font16WhiteBold),
          Text(specialization, style: AppTextStyles.font14GreyRegular),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: AppDecorations.containerDecoration.copyWith(
                  color: AppColors.primary,
                ),
                child: Text(
                  '⭐ ${rating.toStringAsFixed(1)}',
                  style: AppTextStyles.font14WhiteRegular,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: AppDecorations.containerDecoration.copyWith(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: AppTextStyles.font14GreyRegular.copyWith(
                    color: isActive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('$membersCount', style: AppTextStyles.font16WhiteBold),
                    Text('Members', style: AppTextStyles.font14GreyRegular),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('$sessionsCount', style: AppTextStyles.font16WhiteBold),
                    Text('Sessions', style: AppTextStyles.font14GreyRegular),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
