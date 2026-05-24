import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_dropdown_menu.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';

import '../../../../generated/l10n.dart';
import '../../home/ui/widgets/days_containers_screen.dart';

class DesignPlanManuallyScreen extends StatefulWidget {
  const DesignPlanManuallyScreen({super.key});
  static const String routeName='/design-manually';

  @override
  State<DesignPlanManuallyScreen> createState() => _DesignPlanManuallyScreenState();
}

class _DesignPlanManuallyScreenState extends State<DesignPlanManuallyScreen> {
  late TextEditingController controller;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller=TextEditingController(text: 'My Custom Plan');
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  int? selectedDays;

  @override
  Widget build(BuildContext context) {
    final s =S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(s.create_your_plan, style: AppTextStyles.font16WhiteBold,),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        decoration: AppDecorations.containerDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.step_1_basics, style: AppTextStyles.font16WhiteBold,),
            vGap(10),
            Text(s.plan_name, style: AppTextStyles.font16WhiteRegular,),
            vGap(5),
            CustomTextFormField(textInputType: TextInputType.text, controller: controller,),
            vGap(10),
            Text(s.training_days_per_week, style: AppTextStyles.font16WhiteRegular,),
            vGap(5),
            // Dropdown
            CustomDropdown<int>(
              items: List.generate(7, (index) => index + 1),
              labelBuilder: (e) => '$e Day${e > 1 ? 's' : ''}',
              hint: selectedDays != null
                  ? 'Selected: $selectedDays Day${selectedDays! > 1 ? 's' : ''}'
                  : 'Select number of days',
              value: selectedDays,
              onChanged: (value) {
                setState(() {
                  selectedDays = value;
                });
              },
            ),
            vGap(10),
            CustomButton(text: s.create_plan, onPressed: selectedDays != null
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DaysContainersScreen(days: selectedDays!),
                ),
              );
            }
                : null,)
          ],
        ),
      ),
    );
  }
}






