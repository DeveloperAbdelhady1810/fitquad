import 'package:flutter/material.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class SuggestedPrompts extends StatelessWidget {
  final List<String> prompts;
  final void Function(String) onTap;

  const SuggestedPrompts({required this.prompts, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: prompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            backgroundColor: AppColors.secondary,
            label: Text(prompts[index] , style: AppTextStyles.font14GreyRegular,),
            onPressed: () => onTap(prompts[index]),
          );
        },
      ),
    );
  }
}
