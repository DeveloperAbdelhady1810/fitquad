import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/admin/data/plan_model.dart';

class PlanCard extends StatelessWidget {
final PlanModel planModel;
  const PlanCard({super.key,required this.planModel });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.symmetric(horizontal: 10),
      height: MediaQuery.of(context).size.height*0.35,
      decoration: AppDecorations.containerDecoration.copyWith(
        border: Border(top: BorderSide(color: Colors.purpleAccent , width: 3)),

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(planModel.name, style: AppTextStyles.font14GreyRegular,),
          vGap(5),
          Row(
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${planModel.price}💲 ', style: AppTextStyles.font16WhiteBold,),
              Text('/month', style: AppTextStyles.font14GreyRegular,)
            ],
          ),
          vGap(10),
          ...planModel.access.map((e) => Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green,),
              hGap(5),
              Text(e, style: AppTextStyles.font14GreyRegular,)
            ],
          ),),
          const Divider(),
          Text('${planModel.active} Active Members', style: AppTextStyles.font16WhiteBold,),
          vGap(10),
          CustomButton(text: 'Edit plan', onPressed: () {

          },
          color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
