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

class EatTab extends StatefulWidget {
  const EatTab({super.key});

  @override
  State<EatTab> createState() => _EatTabState();
}

class _EatTabState extends State<EatTab> {
  bool _showOptions = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, _) {
        final cubit       = context.read<MemberCubit>();
        final plan        = cubit.nutritionPlan;
        final coaches     = cubit.myCoaches;
        final myCoach     = coaches.firstWhere(
          (c) => c['coach_type'] == 'nutrition' || c['coach_type'] == 'both',
          orElse: () => coaches.isNotEmpty ? coaches.first : <String, dynamic>{},
        );
        final hasCoach = myCoach.isNotEmpty;

        // ── No plan yet: show option tiles ────────────────────────
        if (plan == null) {
          return _OptionsList(s: s, hasCoach: hasCoach, myCoach: myCoach);
        }

        // ── Active plan: show plan card + collapsible options ─────
        final title    = plan['title'] as String? ?? 'Nutrition Plan';
        final calories = (plan['daily_calories'] as num?)?.toInt() ?? 0;
        final protein  = (plan['protein_g'] as num?)?.toInt() ?? 0;
        final carbs    = (plan['carbs_g'] as num?)?.toInt() ?? 0;
        final fat      = (plan['fat_g'] as num?)?.toInt() ?? 0;
        final meals    = (plan['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: AppTextStyles.font16WhiteBold
                                .copyWith(fontSize: 20.sp)),
                        vGap(2),
                        Text('Active Nutrition Plan',
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(color: AppColors.emerald, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  Icon(Icons.restaurant_menu, color: AppColors.emerald, size: 28.r),
                ],
              ),
              vGap(16),

              // Macros row
              Row(
                children: [
                  _MacroBox('Calories', '$calories kcal', AppColors.red),
                  hGap(8),
                  _MacroBox('Protein', '${protein}g', AppColors.blue),
                  hGap(8),
                  _MacroBox('Carbs', '${carbs}g', AppColors.emerald),
                  hGap(8),
                  _MacroBox('Fat', '${fat}g', AppColors.purple),
                ],
              ),
              vGap(16),

              // Meals list
              Text('Meals', style: AppTextStyles.font16WhiteBold),
              vGap(8),
              if (meals.isEmpty)
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text('No meals defined in this plan.',
                      style: AppTextStyles.font14GreyRegular),
                )
              else
                ...meals.map((meal) => _MealRow(meal: meal)),

              vGap(20),

              // Change Plan toggle
              GestureDetector(
                onTap: () => setState(() => _showOptions = !_showOptions),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: AppColors.teal, size: 18.r),
                      hGap(10),
                      Text('Change Plan',
                          style: AppTextStyles.font14WhiteRegular
                              .copyWith(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      Icon(
                        _showOptions ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.grey,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),

              if (_showOptions) ...[
                vGap(12),
                _OptionsList(s: s, hasCoach: hasCoach, myCoach: myCoach),
              ],

              vGap(16),
            ],
          ),
        );
      },
    );
  }
}

// ── Options list (reused when no plan and in Change Plan section) ──────────────

class _OptionsList extends StatelessWidget {
  final dynamic s;
  final bool hasCoach;
  final Map<String, dynamic> myCoach;

  const _OptionsList({required this.s, required this.hasCoach, required this.myCoach});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
  }
}

// ── Macro box ─────────────────────────────────────────────────────────────────

class _MacroBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroBox(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.font14WhiteRegular.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp),
                textAlign: TextAlign.center),
            vGap(2),
            Text(label,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 9.sp),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ── Meal row ──────────────────────────────────────────────────────────────────

class _MealRow extends StatelessWidget {
  final Map<String, dynamic> meal;
  const _MealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    final name       = meal['name'] as String? ?? 'Meal';
    final timeOfDay  = meal['time_of_day'] as String? ?? '';
    final foods      = meal['foods'] as String? ?? '';

    final timeIcon = switch (timeOfDay) {
      'breakfast' => Icons.wb_sunny_outlined,
      'lunch'     => Icons.light_mode_outlined,
      'dinner'    => Icons.nights_stay_outlined,
      'snacks'    => Icons.coffee_outlined,
      _           => Icons.restaurant_outlined,
    };
    final timeColor = switch (timeOfDay) {
      'breakfast' => AppColors.emerald,
      'lunch'     => const Color(0xFFFFD700),
      'dinner'    => AppColors.blue,
      'snacks'    => AppColors.teal,
      _           => AppColors.grey,
    };

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: timeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(timeIcon, color: timeColor, size: 18.r),
          ),
          hGap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                if (foods.isNotEmpty) ...[
                  vGap(2),
                  Text(foods,
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(fontSize: 11.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: timeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(timeOfDay,
                style: AppTextStyles.font14GreyRegular.copyWith(
                    color: timeColor, fontSize: 10.sp)),
          ),
        ],
      ),
    );
  }
}
