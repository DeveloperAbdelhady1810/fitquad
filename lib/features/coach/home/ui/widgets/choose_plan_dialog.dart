import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_dropdown_menu.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';
import 'package:gym_app/features/coach/home/manager/coach_cubit.dart' ;
import 'package:gym_app/features/member/data/models/member_model.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';

Future<void> showChoosePlanDialog(BuildContext context) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (dialogContext) {
      final s = S.of(context);
      return BlocProvider.value(
        value:context.read<CoachCubit>() ,

      child:  Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          padding: const EdgeInsets.all(10),
          decoration: AppDecorations.containerDecoration.copyWith(
            color: AppColors.primary,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(s.create_workout_plan, style: AppTextStyles.font16WhiteBold,),
                  subtitle: Text(s.design_new_training_program, style: AppTextStyles.font14GreyRegular,),
                  trailing: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close, color: AppColors.grey,)),
            
                ),
                vGap(10),
                BlocBuilder<CoachCubit, CoachState>(
                  builder: (context, state) {
                    if (state is CoachesLoaded) {
                      return SingleChildScrollView(
                        child : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.select_member, style: AppTextStyles.font14WhiteRegular,),
                            vGap(5),
                            CustomDropdown<MemberModel>(
                              hint: 'Select member',
                              items: state.allMembers,
                              value: null,
                              labelBuilder: (member) => member.name??'',
                              onChanged: (member) {},
                            ),
                            vGap(10),
                            Text(s.plan_name, style: AppTextStyles.font14WhiteRegular,),
                            vGap(5),
                            CustomTextFormField(textInputType: TextInputType.text, hintText: 'eg. Hypertrophy',),
                            vGap(10),
                            Text(s.duration_weeks, style: AppTextStyles.font14WhiteRegular,),
                            vGap(5),
                            CustomDropdown<String>(
                              hint: 'select ',
                              items: ['4 weeks' , '8 weeks', '12 weeks'],
                              value: '4 weeks',
                              labelBuilder: (e) => e,
                              onChanged: (e) {},
                            ),
                          ],
                        ),
                      );
                    }
            
                    return const SizedBox();
                  },
                ),
                vGap(20),
                CustomButton(text: s.create_draft, onPressed: () => context.pop(),)
            
              ],
            ),
          ),
        ),
      ),
      );
    },
  );
}
