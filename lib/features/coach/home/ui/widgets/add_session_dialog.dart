import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_dropdown_menu.dart';
import 'package:gym_app/features/coach/home/manager/coach_cubit.dart' ;
import 'package:gym_app/features/member/data/models/member_model.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';

Future<void> showAddSessionDialog(BuildContext context , TextEditingController dateController  , TextEditingController timeController  ) async {
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
                    title: Text(s.schedule_session, style: AppTextStyles.font16WhiteBold,),
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
                              CustomDropdown<MemberModel>(
                                hint: 'Select member',
                                items: state.allMembers,
                                value: null,
                                labelBuilder: (member) => member.name??'',
                                onChanged: (member) {},
                              ),
                              vGap(10),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(

                                      controller: dateController,
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintStyle: AppTextStyles.font14GreyRegular,

                                        border: const OutlineInputBorder(

                                          borderRadius: BorderRadius.all(Radius.circular(14))

                                        ),
                                        hintText: 'Select date',
                                      ),
                                      onTap: () async {
                                        final pickedDate = await showDatePicker(
                                          context: context,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2030),
                                          initialDate: DateTime.now(),
                                        );

                                        if (pickedDate != null) {
                                          dateController.text =
                                          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(

                                      controller: timeController,
                                      readOnly: true,
                                      decoration:  InputDecoration(
                                        hintStyle: AppTextStyles.font14GreyRegular,
                                        hintText: 'Select time',

                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(14))

                                        ),
                                      ),
                                      onTap: () async {
                                        final pickedTime = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );

                                        if (pickedTime != null) {
                                          timeController.text = pickedTime.format(context);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),


                            ],
                          ),
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                  vGap(20),
                  CustomButton(text: s.create_draft, onPressed: () => context.pop(), color: Colors.orange,)

                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
