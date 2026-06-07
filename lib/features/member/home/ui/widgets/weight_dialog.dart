import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/features/member/home/ui/widgets/weight_tab_bar_view.dart';

import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';
import 'analysis_tab_bar_view.dart';

Future<void> showWeightDialog(BuildContext context) async {
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
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.balance, color: AppColors.emerald),
                    title: Text(s.weight_tracker, style: AppTextStyles.font16WhiteBold),
                    subtitle: Text(s.track_progress, style: AppTextStyles.font14GreyRegular),
                    trailing: IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close, color: AppColors.grey),
                    ),
                  ),
                  const Divider(),
                  vGap(10),
                  CustomTabBar(
                    tabs: [Text(s.log_weight), Text(s.analysis_projection)],
                  ),
                  vGap(10),
                  const Expanded(
                    child: TabBarView(
                      children: [WeightTabBarView(), AnalysisTabBarView()],
                    ),
                  ),
                  const Divider(),
                  CustomButton(
                    text: s.save_changes,
                    onPressed: () async {
                      await cubit.saveDashboardToApi();
                      if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
