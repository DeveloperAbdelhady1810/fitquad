import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

Future<void> showSleepDialog(BuildContext context) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (dialogContext) {

      return BlocProvider.value(
        value: context.read<MemberCubit>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(10),
            decoration: AppDecorations.containerDecoration.copyWith(
              color: AppColors.primary,
            ),
            child: BlocBuilder<MemberCubit, MemberState>(
              builder: (context, state) {
                final s = S.of(context);

                if (state is MemberLoading) {
                  return const CircularProgressIndicator();
                }

                if (state is MemberLoaded) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.nightlight_outlined,
                          color: AppColors.emerald,
                        ),
                        title: Text(
                          s.weight_tracker,
                          style: AppTextStyles.font16WhiteBold,
                        ),
                        subtitle: Text(
                          s.track_progress,
                          style: AppTextStyles.font14GreyRegular,
                        ),
                        trailing: IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.close, color: AppColors.grey),
                        ),
                      ),

                      const Divider(),
                      vGap(10),
                      Container(
                        decoration: AppDecorations.containerDecoration,
                        child: ListTile(
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            mainAxisAlignment: MainAxisAlignment.center,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${state.member.sleepHrs ?? 0}',
                                style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 20.sp),
                              ),
                              hGap(5),
                              Text(
                                s.hrs,
                                style: AppTextStyles.font14GreyRegular,
                              ),
                            ],
                          ),
                          subtitle: Center(
                            child: Text(
                              state.member.sleepHrs! < 6.5
                                  ? s.below_recommended_amount
                                  : s.optimal_recovery_zone,
                              style: AppTextStyles.font16GreyRegular.copyWith(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      vGap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '4 ${s.hrs}',
                            style: AppTextStyles.font16WhiteRegular,
                          ),
                          Text(
                            '8 ${s.hrs}',
                            style: AppTextStyles.font16WhiteRegular,
                          ),
                          Text(
                            '12 ${s.hrs}',
                            style: AppTextStyles.font16WhiteRegular,
                          ),
                        ],
                      ),
                      Slider(
                        activeColor: AppColors.emerald,
                        min: 4,
                        max: 12,
                        divisions: 16,
                        value: (state.member.sleepHrs ?? 8).clamp(4, 12),
                        onChanged: (value) {
                          context.read<MemberCubit>().updateSleepHrs(value);
                        },
                      ),
                      vGap(10),
                      Container(
                        decoration: AppDecorations.containerDecoration,
                        child: ListTile(
                          leading: Icon(
                            Icons.nightlight_outlined,
                            color: AppColors.babyBlue,
                          ),
                          title: Text(
                            s.why_it_matters,
                            style: AppTextStyles.font16WhiteBold.copyWith(
                              color: AppColors.babyBlue,
                            ),
                          ),
                          subtitle: Text(
                            s.sleep_importance_description,
                            style: AppTextStyles.font14GreyRegular.copyWith(
                              color: AppColors.babyBlue,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Divider(),
                      CustomButton(
                        text: s.save_changes,
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    },
  );
}
