import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_list_tile.dart';
import 'package:gym_app/features/member/home/manager/bottom_nav_bar_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/home/ui/widgets/member_chat_screen.dart';

import '../../../../core/enums/choose_coach.dart';
import '../../../../generated/l10n.dart';
import '../../home/ui/widgets/choose_coach_screen.dart';
import 'design_nutritio_manualy_screen.dart';

class EatTab extends StatelessWidget {
  const EatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, _) {
        final coaches = context.read<MemberCubit>().myCoaches;
        // Use the first nutrition/both coach, or any coach if none typed
        final myCoach = coaches.firstWhere(
          (c) => c['coach_type'] == 'nutrition' || c['coach_type'] == 'both',
          orElse: () => coaches.isNotEmpty ? coaches.first : <String, dynamic>{},
        );
        final hasCoach = myCoach.isNotEmpty;

        return Column(
          children: [
            Text(
              s.fuel_your_body,
              style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 22.sp),
            ),
            vGap(10),
            Text(
              s.choose_how_to_build_plan,
              style: AppTextStyles.font16GreyRegular,
              textAlign: TextAlign.center,
            ),
            vGap(10),
            CustomListTile(
              title: s.set_manually,
              subTitle: s.input_your_own_macros_and_meals,
              icon: Icons.edit,
              color: Colors.deepOrange,
              onTap: () => context.push(DesignNutritionManuallyScreen.routeName),
            ),
            vGap(10),
            CustomListTile(
              title: s.ask_ai_coach,
              subTitle: s.generate_a_meal_plan_instantly,
              icon: Icons.smart_toy_outlined,
              color: Colors.green,
              onTap: () => context.read<BottomNavBarCubit>().changeIndex(2),
            ),
            vGap(10),
            // Show subscribed coach as primary option, or Find a Coach otherwise
            if (hasCoach) ...[
              CustomListTile(
                title: 'Ask ${myCoach['name'] ?? 'My Coach'}',
                subTitle: 'Request a nutrition plan from your coach',
                icon: Icons.sports_gymnastics,
                color: AppColors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemberChatScreen(
                      coachName: myCoach['name'] as String? ?? 'Coach',
                    ),
                  ),
                ),
              ),
              vGap(10),
            ],
            CustomListTile(
              title: s.real_coach,
              subTitle: hasCoach
                  ? 'Find another coach for nutrition'
                  : s.request_a_plan_from_your_trainer,
              icon: Icons.person_outline,
              color: AppColors.purple,
              onTap: () => context.push(
                ChooseCoachScreen.routeName,
                extra: ChooseCoachSource.eat,
              ),
            ),
          ],
        );
      },
    );
  }
}
