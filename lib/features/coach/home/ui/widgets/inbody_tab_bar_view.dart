import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';

import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_feild.dart';
import '../../../../../generated/l10n.dart';

class InBodyTabBarView extends StatelessWidget {
  const InBodyTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= AI INSIGHTS CARD =================
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: AppDecorations.containerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Insights",
                  style: AppTextStyles.font16WhiteBold,
                ),
                vGap(10),
                Text(
                  "Your muscle mass increased by 1.2kg compared to last report. "
                      "Keep maintaining your protein intake and strength training.",
                  style: AppTextStyles.font14GreyRegular,
                ),
              ],
            ),
          ),

          vGap(20),

          /// ================= LATEST REPORT CARD =================
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: AppDecorations.containerDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Latest Report",
                  style: AppTextStyles.font16WhiteBold,
                ),
                vGap(15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("Weight", "72 kg"),
                    _buildMetric("Body Fat", "18%"),
                    _buildMetric("Muscle", "34 kg"),
                  ],
                ),

                vGap(15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric("BMI", "23.1"),
                    _buildMetric("Water", "55%"),
                    _buildMetric("BMR", "1650"),
                  ],
                ),
              ],
            ),
          ),

          vGap(25),

          /// ================= HISTORY =================
          Text(
            s.history,
            style: AppTextStyles.font14GreyRegular,
          ),
          vGap(10),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Container(
              decoration: AppDecorations.containerDecoration,
              padding: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(
                  "Report ${index + 1}",
                  style: AppTextStyles.font16WhiteRegular,
                ),
                subtitle: Text(
                  "12 Feb 2026",
                  style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
            separatorBuilder: (_, __) => vGap(10),
            itemCount: 4,
          ),

          vGap(25),

          /// ================= COACH COMMENTS =================
          Text(
            s.coach_comments,
            style: AppTextStyles.font16WhiteBold,
          ),
          vGap(5),

          CustomTextFormField(
            textInputType: TextInputType.text,
            maxLines: 3,
          ),

          vGap(10),

          CustomButton(
            color: AppColors.secondary,
            width: 120.w,
            text: s.save_comments,
            onPressed: () {},
          ),

          vGap(30),
        ],
      ),
    );
  }

  Widget _buildMetric(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.font16WhiteBold,
        ),
        vGap(4),
        Text(
          title,
          style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}