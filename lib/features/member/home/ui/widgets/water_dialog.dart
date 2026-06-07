import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/member/home/ui/widgets/water_circular_slider.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

Future<void> showWaterDialog(BuildContext context) async {
  if (!context.mounted) return;

  final cubit = context.read<MemberCubit>();

  await showDialog(
    context: context,
    builder: (dialogContext) {
      final s = S.of(context);

      return BlocProvider.value(
        value: cubit,
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
              builder: (_, state) {
                if (state is MemberLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                }

                if (state is MemberLoaded || state is MemberUpdated) {
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.water_drop_outlined, color: AppColors.purple),
                        title: Text(s.hydration, style: AppTextStyles.font16WhiteBold),
                        subtitle: Text(s.hydration_description, style: AppTextStyles.font14GreyRegular),
                        trailing: IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close, color: AppColors.grey),
                        ),
                      ),
                      const Divider(),
                      vGap(10),
                      const WaterSlider(),
                      vGap(10),
                      Text(s.hydration_daily_goal, style: AppTextStyles.font16GreyRegular),
                      const Spacer(),
                      const Divider(),
                      CustomButton(
                        text: s.save_changes,
                        onPressed: () async {
                          await cubit.saveDashboardToApi();
                          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
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
