import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';

import '../../../../generated/l10n.dart';
import '../../home/ui/widgets/food_dialog.dart';
import 'meal_card.dart';

class NutritionOverviewScreen extends StatefulWidget {
  final List<MealModel> meals;

  const NutritionOverviewScreen({
    super.key,
    required this.meals,
  });

  static const String routeName='/nutrition-overview';

  @override
  State<NutritionOverviewScreen> createState() => _NutritionOverviewScreenState();
}

class _NutritionOverviewScreenState extends State<NutritionOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title:  Text(s.nutrition, style: AppTextStyles.font16WhiteBold,),
        iconTheme: IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.pushReplacement(BottomNavBarView.routeName),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: ()=> showFoodDialog(context),
              icon: const Icon(Icons.add, size: 18 , color: Colors.white,),
              label:  Text(s.log_food, style: AppTextStyles.font16WhiteBold,),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Target
            const Text(
              'Target: 1999 kcal',
              style: TextStyle(color: Colors.white54),
            ),

            const SizedBox(height: 16),

            /// Macros
            Row(
              children:  [
                Expanded(child: MacroCard(title: s.carbs, percent: 50)),
                SizedBox(width: 12),
                Expanded(child: MacroCard(title: s.protein, percent: 30)),
                SizedBox(width: 12),
                Expanded(child: MacroCard(title: s.fat, percent: 20)),
              ],
            ),

            vGap(20),

            /// Daily Timetable
             Text(
              s.daily_timetable,
              style: AppTextStyles.font16WhiteBold,
            ),
            vGap(10),

            ...widget.meals.map(
                  (meal) => MealTile(
                time: meal.time,
                title: meal.title,
                subtitle: meal.food,
              ),
            ),

            vGap(20),

            /// Bottom Stats
            Row(
              children:  [
                Expanded(
                  child: InfoCard(
                    icon: Icons.water_drop,
                    title: '1.5L',
                    subtitle:s.water_intake,
                    gradient: [AppColors.secondary,AppColors.primary],
                  ),
                ),
                hGap(10),
                Expanded(
                  child: InfoCard(
                    icon: Icons.nightlight_round,
                    title: '7h 20m',
                    subtitle: '${s.sleep_duration}\n${s.target} 8h',
                    gradient: [Color(0xFF3B145F), Color(0xFF1C0C2E)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class MealTile extends StatelessWidget {
  final String time;
  final String title;
  final String subtitle;

  const MealTile({
    super.key,
    required this.time,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF151A30), Color(0xFF0E1325)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Colors.white54),
                  const SizedBox(width: 6),
                  Text(time,
                      style: const TextStyle(color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 6),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.white54)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: Colors.white54),
        ],
      ),
    );
  }
}

class MacroCard extends StatelessWidget {
  final String title;
  final int percent;

  const MacroCard({
    super.key,
    required this.title,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151A30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white54)),
          const Spacer(),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Colors.white12,
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120.h,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          const Spacer(),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(subtitle,
              style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}