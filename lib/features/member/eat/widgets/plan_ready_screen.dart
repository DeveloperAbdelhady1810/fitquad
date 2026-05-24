import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/eat/widgets/nutrition_proposal_dialog.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';

import '../../../../../generated/l10n.dart';
import '../../../../core/enums/choose_coach.dart';
import '../../train/widgets/coach_proposal_dialog.dart';

class PlanReadyScreen extends StatelessWidget {
  final ChooseCoachSource source;

  const PlanReadyScreen({super.key, required this.source});
  static const String routeName = '/plan-ready';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.primary),
      backgroundColor: AppColors.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 45.r,
            backgroundColor: Colors.green.withValues(alpha: 0.2),
            child: Icon(Icons.check, color: Colors.green, size: 50.sp),
          ),
          vGap(20),
          Center(
            child: Text(
              s.plan_ready,
              style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 20.sp),
            ),
          ),
          Center(
            child: Text(
              s.plan_ready_message,
              style: AppTextStyles.font16GreyRegular,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () =>
                context.pushReplacement(BottomNavBarView.routeName),
            child: Text(
              s.back_to_dashboard,
              style: AppTextStyles.font16GreyRegular,
            ),
          ),
          vGap(10),
          CustomButton(text: s.view_plan,
            onPressed: () {
            if (source == ChooseCoachSource.train) {
              showProposalDialog(context, );
            } else {
              showNutritionProposalDialog(context, );
            }

          },),
           vGap(10),
          CustomButton(
            color:Colors.black54 ,
            text: s.close,
            onPressed: () =>
                context.pushReplacement(BottomNavBarView.routeName),
          ),
        ],
      ),
    );
  }
}
