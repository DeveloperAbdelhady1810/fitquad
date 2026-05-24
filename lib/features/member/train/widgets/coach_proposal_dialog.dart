import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';

import '../../../../generated/l10n.dart';
import '../../home/ui/widgets/week_summary_screen.dart';

Future<void> showProposalDialog(BuildContext context) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (dialogContext) {
      final s = S.of(context);

      return Dialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    s.coach_proposal,
                    style: AppTextStyles.font16WhiteBold,
                  ),
                  subtitle: Text(
                    s.review_details_before_accepting,
                    style: AppTextStyles.font16GreyRegular,
                  ),
                  trailing: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: AppColors.white),
                  ),
                ),
                vGap(10),
                Container(
                  decoration: AppDecorations.containerDecoration,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        title: Text(
                          s.target_goal,
                          style: AppTextStyles.font14GreyRegular,
                        ),
                        trailing: Text(
                          s.coach_assigned_training,
                          style: AppTextStyles.font14GreyRegular.copyWith(
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                      vGap(5),
                      const Divider(),
                      vGap(5),
                      Text(s.target_goal,
                          style: AppTextStyles.font16WhiteBold),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => Container(
                          decoration: AppDecorations.containerDecoration
                              .copyWith(color: AppColors.primary),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('data',
                                  style: AppTextStyles.font16WhiteRegular),
                              Text(
                                'data',
                                style: AppTextStyles.font16WhiteRegular.copyWith(
                                  color: AppColors.emerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                        separatorBuilder: (context, index) => vGap(5),
                        itemCount: 5,
                      ),
                    ],
                  ),
                ),
                vGap(10),
                CustomButton(
                  text: s.accept_plan,
                  onPressed: () => context.pushReplacement(WeekSummaryScreen.routeName,),
                ),
                vGap(10),
                CustomButton(
                  text: s.reject_plan,
                  onPressed: () => context.pop(),
                  color: AppColors.red.withValues(alpha: 0.2),
                  textStyle: AppTextStyles.font16WhiteRegular
                      .copyWith(color: AppColors.red),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}