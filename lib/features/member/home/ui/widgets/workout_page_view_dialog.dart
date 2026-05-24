import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/services/health_service.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

Future<void> showWorkoutPageViewDialog(BuildContext context) async {
  if (!context.mounted) return;

  final cubit = context.read<MemberCubit>();
  await cubit.restoreWorkout();

  final pageController = PageController(initialPage: cubit.currentExercise);

  showDialog(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: cubit,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: BlocBuilder<MemberCubit, MemberState>(
            builder: (context, state) {

              return Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: AppDecorations.containerDecoration.copyWith(
                  color: AppColors.primary,
                ),
                child: Column(
                  children: [

                    // PageView Exercises
                    Expanded(
                      child: PageView.builder(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cubit.totalExercises,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListTile(
                                title: Text(
                                  'Upper Body',
                                  style: AppTextStyles.font16WhiteBold,
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    cubit.isWorkoutPaused
                                        ? Icons.play_arrow
                                        : Icons.pause,
                                  ),
                                  onPressed: cubit.togglePause,
                                ),
                              ),
                              const Divider(),
                              vGap(10),
                              // Exercise counter
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 40,
                                ),
                                height: MediaQuery.of(context).size.height * 0.2,
                                width: MediaQuery.of(context).size.width * 0.6,
                                decoration: AppDecorations.containerDecoration,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.fitness_center,
                                      color: AppColors.teal,
                                      size: 50.sp,
                                    ),
                                    Text(
                                      "Exercise ${cubit.currentExercise + 1} of ${cubit.totalExercises}"
                                          .toUpperCase(),
                                      style: AppTextStyles.font16GreyRegular,
                                    ),
                                  ],
                                ),
                              ),

                              vGap(12),

                              Text(
                                'Lateral Raises',
                                style: AppTextStyles.font16WhiteBold,
                              ),
                              vGap(20),
                              Text(
                                '3 sets x 15 reps',
                                style: AppTextStyles.font16GreyRegular.copyWith(
                                  color: AppColors.teal,
                                ),
                              ),




                            ],
                          );
                        },
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButton(
                          text: "Previous",
                          width: 150,
                          onPressed: cubit.currentExercise > 0
                              ? () {
                            cubit.previousExercise();
                            pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                              : null,
                        ),
                        hGap(12),
                        CustomButton(
                          text: cubit.currentExercise == cubit.totalExercises - 1
                              ? "Finish"
                              : "Next",
                          width: 150,
                          onPressed: () {
                            if (cubit.currentExercise == cubit.totalExercises - 1) {
                              final sessionStart = DateTime.now().subtract(
                                Duration(seconds: cubit.totalSeconds),
                              );
                              cubit.finishWorkout();
                              HealthService.writeWorkout(
                                calories: 320,
                                duration: Duration(seconds: cubit.totalSeconds),
                                start: sessionStart,
                              );
                              context.pop();
                            } else {
                              cubit.nextExercise();
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                        ),
                      ],
                    ),


                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
