import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/enums/availability.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../generated/l10n.dart';
import '../../manager/onboarding_cubit.dart';

class StepDuration extends StatelessWidget {
  const StepDuration({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final selected =
        state is OnboardingChanged ? state.duration : null;
        final s = S.of(context);

        List<String> strings= [
          s.express,
          s.standard,
          s.optimal,
          s.extended
        ];
        return Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            children:[
              CircleAvatar(
                backgroundColor: AppColors.purple.withValues(alpha: 0.3),
                radius: 25.r,
                child: Icon(Icons.timelapse, color: AppColors.purple, size: 25.sp),
              ),
              vGap(10),
              Text(s.session_duration, style: AppTextStyles.font16WhiteBold),
              vGap(5),
              Text(s.session_duration_question, style: AppTextStyles.font14GreyRegular),
              vGap(15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5
                  ,
                ),
                itemCount: WorkoutDuration.values.length,
                itemBuilder: (context, index) {
                  final d = WorkoutDuration.values[index];
                  final isSelected = selected == d;

                  return GestureDetector(
                    onTap: () {
                      context.read<OnboardingCubit>().setDuration(d);
                    },
                    child: Container(
                      margin: EdgeInsets.all(15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.secondary,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.purple
                              : Colors.grey.shade400,
                          width: 2,
                        ),

                      ),
                      child:
                      ListTile(
                        title:Text(
                            d.title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.font16WhiteBold
                        ) ,
                        subtitle:Text(
                            strings[index],
                            textAlign: TextAlign.center,
                            style: AppTextStyles.font14GreyRegular
                        ) ,
                      ),

                    ),
                  );
                },
              ),

            ],
          ),
        );
      },
    );
  }
}
