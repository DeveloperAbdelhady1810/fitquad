import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_list_tile.dart';
import 'package:gym_app/features/member/home/ui/widgets/choose_coach_screen.dart';
import 'package:gym_app/features/member/train/widgets/design_manually_screen.dart';

import '../../../../core/enums/choose_coach.dart';
import '../../../../generated/l10n.dart';
import '../../home/manager/bottom_nav_bar_cubit.dart';

class TrainTab extends StatelessWidget {
  const TrainTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      children: [
        Text(
          s.lets_get_started,
          style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 22.sp),
        ),
        vGap(10),
        Text(
          s.choose_plan_method,
          style: AppTextStyles.font16GreyRegular,
          textAlign: TextAlign.center,
        ),
        vGap(10),
        CustomListTile(
          title: s.design_manually,
          subTitle: s.select_days_exercises,
          icon: Icons.edit,
          color: Colors.indigo,
          onTap: () => context.push(DesignPlanManuallyScreen.routeName),
        ),
        vGap(10),
        CustomListTile(
          title: s.ask_ai_coach,
          subTitle: s.instant_personalized_plan,
          icon: Icons.smart_toy_outlined,
          color: Colors.green,
          onTap: () => context.read<BottomNavBarCubit>().changeIndex(2),
        ),
        vGap(10),
        CustomListTile(
          title: s.real_coach,
          subTitle: s.request_professional_plan,
          icon: Icons.person_outline,
          color: AppColors.purple,
          onTap: () => context.push(ChooseCoachScreen.routeName , extra: ChooseCoachSource.train,
          ),
        ),
      ],
    );
  }
}
