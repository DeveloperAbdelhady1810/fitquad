import 'package:flutter/material.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_dropdown_menu.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';

class SettingsBody extends StatefulWidget {
  const SettingsBody({super.key});

  @override
  State<SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  late TextEditingController nameController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: 'IronPulse Gym');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
  }

  String? selectedLanguage;
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: AppDecorations.containerDecoration,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('General Settings', style: AppTextStyles.font16WhiteBold),
              vGap(10),
              Text('Gym Name', style: AppTextStyles.font16WhiteRegular),
              vGap(5),
              CustomTextFormField(
                icon: Icons.fitness_center,
                textInputType: TextInputType.text,
                controller: nameController,
                hintText: nameController.text,
              ),
              vGap(10),
              Text('Language', style: AppTextStyles.font16WhiteRegular),
              vGap(5),
              CustomDropdown(
                items: ['English', 'Arabic'],
                labelBuilder: (e) => e,
                value: selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value;
                  });
                },
                hint: 'Language',
              ),
            ],
          ),
        ),
        vGap(10),
        Container(
          decoration: AppDecorations.containerDecoration,
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Security', style: AppTextStyles.font16WhiteBold),
              ListTile(
                title: Text(
                  'Two-factor Authentication',
                  style: AppTextStyles.font16WhiteBold,
                ),
                subtitle: Text(
                  'Secure your account with 2FA ',
                  style: AppTextStyles.font14GreyRegular,
                ),
                trailing: Switch(
                  activeThumbColor: AppColors.grey,
                  value:isSwitched ,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
