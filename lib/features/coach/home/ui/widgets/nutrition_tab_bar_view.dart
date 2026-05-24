import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

import '../../../../../generated/l10n.dart';
import '../../../../admin/ui/widgets/pie_chart.dart';

class NutritionTabBarView extends StatelessWidget {
  const NutritionTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: AppDecorations.containerDecoration,
          padding: EdgeInsets.all(10),
          child: ListTile(
            title: Text(s.daily_targets, style: AppTextStyles.font16WhiteBold),
            subtitle: Text('data', style: AppTextStyles.font14GreyRegular),
            trailing: CircularProgressIndicator(
              value: 0.5,
              color: AppColors.emerald,
              backgroundColor: AppColors.grey,
            ),
          ),
        ),
        vGap(10),
        Container(
          decoration: AppDecorations.containerDecoration,
          child: PieChartWidget(),
        ),
        vGap(10),
        Container(
          decoration: AppDecorations.containerDecoration,
          padding: EdgeInsets.all(10),
          child: ListTile(
            leading: Container(
              padding: EdgeInsets.all(10),
              decoration: AppDecorations.containerDecoration.copyWith(
                color: AppColors.emerald.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(5)
                
              ),
              child: Icon(Icons.menu_sharp, color: AppColors.emerald,),
            ),
            title: Text('data', style: AppTextStyles.font16WhiteBold),
            subtitle: Text('data', style: AppTextStyles.font14GreyRegular),
            trailing: TextButton(
              onPressed: () {},
              child: Text('good', style: AppTextStyles.font14GreyRegular.copyWith(color: AppColors.emerald)),
            ),
          ),
        ),
        vGap(5),
        Text(s.daily_meal_plan, style: AppTextStyles.font16GreyRegular),
        vGap(10),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) => Container(
              decoration: AppDecorations.containerDecoration,
              padding: EdgeInsets.all(10),
              child: ListTile(
                title: Text('data', style: AppTextStyles.font16WhiteBold),
                subtitle: Text('data', style: AppTextStyles.font14GreyRegular),
                trailing: TextButton(
                  onPressed: () {},
                  child: Text(s.edit, style: AppTextStyles.font14GreyRegular),
                ),
              ),
            ),
            separatorBuilder: (context, index) => vGap(10),
            itemCount: 4,
          ),
        ),
      ],
    );
  }
}
