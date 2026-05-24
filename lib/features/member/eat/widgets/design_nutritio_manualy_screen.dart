import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_dropdown_menu.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_text_feild.dart';
import '../../../../generated/l10n.dart';
import 'nutrition_plan_screen.dart';

class DesignNutritionManuallyScreen extends  StatefulWidget {
  const DesignNutritionManuallyScreen({super.key});
  static const String routeName ='/nutrition-manually';

  @override
  State<DesignNutritionManuallyScreen> createState() => _DesignNutritionManuallyScreenState();
}

class _DesignNutritionManuallyScreenState extends State<DesignNutritionManuallyScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller=TextEditingController(text: '2000');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }
  String? selectedDiet;

  @override
  Widget build(BuildContext context) {
    final s =S.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(s.nutrition_plan, style: AppTextStyles.font16WhiteBold,),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: AppDecorations.containerDecoration,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.daily_targets, style: AppTextStyles.font16WhiteBold,),
            vGap(10),
            Text(s.daily_calories, style: AppTextStyles.font16WhiteRegular,),
            vGap(5),
            CustomTextFormField(textInputType: TextInputType.text, controller: controller,),
            vGap(10),
            Text(s.diet_type, style: AppTextStyles.font16WhiteRegular,),
            vGap(5),
        CustomDropdown<String>(
          items: const ['Balanced', 'Keto', 'High Protein'],
          labelBuilder: (e) => e,
          hint: 'Select diet type',
          value: selectedDiet,
          onChanged: (value) {
            setState(() {
              selectedDiet = value;
            });
          },
        ),
            vGap(10),
            CustomButton(text: s.next_meals, onPressed: () => context.push(NutritionPlanScreen.routeName),)
          ],
        ),
      ),
    );
  }
}
