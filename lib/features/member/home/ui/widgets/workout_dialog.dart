import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/home/ui/widgets/workout_page_view_dialog.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

Future<void> showWorkoutDialog(
  BuildContext context, {
  required PageController pageController,
}) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) {
      return BlocProvider.value(
        value: context.read<MemberCubit>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: BlocBuilder<MemberCubit, MemberState>(
            builder: (context, state) {
              final s = S.of(context);

              return Container(
                padding: const EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: AppDecorations.containerDecoration.copyWith(
                  color: AppColors.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.emerald.withValues(alpha: 0.3),
                      radius: 40.r,
                      child: Icon(
                        Icons.fitness_center,
                        color: AppColors.emerald,
                        size: 30.sp,
                      ),
                    ),
                    vGap(10),
                    Text('Upper Body Workout', style: AppTextStyles.font16WhiteBold,),


                     Text('8 Exercises • 45 Minutes • 320 kcal', style: AppTextStyles.font14GreyRegular,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(decoration: AppDecorations.containerDecoration, padding: EdgeInsets.all(10),child: Center(
                            child: ListTile(title: Text('data'), subtitle: Text('data'),),
                          ),),
                        ),
                        hGap(5),
                        Expanded(
                          child: Container(decoration: AppDecorations.containerDecoration, padding: EdgeInsets.all(10),child: Center(
                            child: ListTile(title: Text('data'), subtitle: Text('data'),),
                          ),),
                        ),
                      ],
                    ),
                    const Spacer(),

                    const Divider(),
                    vGap(5),
                    CustomButton(
                      onPressed: () => showWorkoutPageViewDialog(
                        context,

                      ),
                      text:
                        s.start_workout,
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
