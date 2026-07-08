import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/ai/ui/ai_plan_prompt_sheet.dart';
import 'package:gym_app/features/member/eat/widgets/design_nutritio_manualy_screen.dart';
import 'package:gym_app/features/member/home/manager/food_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/home/ui/widgets/choose_coach_screen_neo.dart';
import 'package:gym_app/features/member/home/ui/widgets/food_dialog.dart';
import 'package:gym_app/features/member/home/ui/widgets/member_chat_screen.dart';

class EatTabNeo extends StatefulWidget {
  const EatTabNeo({super.key});

  @override
  State<EatTabNeo> createState() => _EatTabNeoState();
}

class _EatTabNeoState extends State<EatTabNeo> {
  bool _showOptions = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final cubit = context.read<MemberCubit>();
        final plan = cubit.nutritionPlan;
        final coaches = cubit.myCoaches;
        final myCoach = coaches.firstWhere(
          (c) => c['coach_type'] == 'nutrition' || c['coach_type'] == 'both',
          orElse: () =>
              coaches.isNotEmpty ? coaches.first : <String, dynamic>{},
        );
        final hasCoach = myCoach.isNotEmpty;

        if (plan == null) {
          return _NoPlan(hasCoach: hasCoach, myCoach: myCoach);
        }

        final calories = (plan['daily_calories'] as num?)?.toInt() ?? 2000;
        final protein = (plan['protein_g'] as num?)?.toInt() ?? 0;
        final carbs = (plan['carbs_g'] as num?)?.toInt() ?? 0;
        final fat = (plan['fat_g'] as num?)?.toInt() ?? 0;
        final meals =
            (plan['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final foodState = context.watch<FoodCubit>().state;
        final consumed = foodState is FoodLoaded ? foodState.caloriesToday.round() : 0;
        final mealCalories = foodState is FoodLoaded ? foodState.caloriesByMealType : <String, double>{};

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NUTRITION',
                style: NeoTextStyles.headlineLg.copyWith(color: NeoColors.cyan),
              ),
              vGap(4),
              Text('DAILY FUEL LOG', style: NeoTextStyles.labelCaps),
              vGap(20),
              Center(
                child: _CalorieRing(goal: calories, consumed: consumed),
              ),
              vGap(20),
              _MacrosRow(protein: protein, carbs: carbs, fat: fat),
              vGap(20),
              Row(
                children: [
                  Container(width: 3.w, height: 16.h, color: NeoColors.cyan),
                  hGap(8),
                  Text(
                    "TODAY'S LOG",
                    style: NeoTextStyles.labelCaps.copyWith(
                      color: NeoColors.cyan,
                    ),
                  ),
                ],
              ),
              vGap(12),
              if (meals.isEmpty) ...[
                _MealCard(
                  icon: Icons.wb_sunny_outlined,
                  name: 'BREAKFAST',
                  kcal: mealCalories['breakfast']?.round() ?? 0,
                  color: NeoColors.lime,
                ),
                _MealCard(
                  icon: Icons.lunch_dining,
                  name: 'LUNCH',
                  kcal: mealCalories['lunch']?.round() ?? 0,
                  color: NeoColors.cyan,
                ),
                _MealCard(
                  icon: Icons.dinner_dining,
                  name: 'DINNER',
                  kcal: mealCalories['dinner']?.round() ?? 0,
                  color: NeoColors.magenta,
                ),
                _MealCard(
                  icon: Icons.apple,
                  name: 'SNACKS',
                  kcal: mealCalories['snacks']?.round() ?? 0,
                  color: NeoColors.lime,
                ),
              ] else
                ...meals.map(
                  (m) => _MealCard(
                    icon: Icons.restaurant,
                    name: (m['name'] as String? ?? 'MEAL').toUpperCase(),
                    kcal: mealCalories[m['time_of_day'] as String? ?? '']
                            ?.round() ??
                        0,
                    color: NeoColors.cyan,
                  ),
                ),
              vGap(20),
              GestureDetector(
                onTap: () => setState(() => _showOptions = !_showOptions),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: NeoColors.cyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, color: NeoColors.cyan, size: 18.r),
                      hGap(10),
                      Text(
                        'CHANGE PLAN',
                        style: NeoTextStyles.labelCaps.copyWith(
                          color: NeoColors.cyan,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _showOptions ? Icons.expand_less : Icons.expand_more,
                        color: NeoColors.outline,
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
              if (_showOptions) ...[
                vGap(12),
                _NutritionOptionsList(hasCoach: hasCoach, myCoach: myCoach),
              ],
              vGap(80.h),
            ],
          ),
        );
      },
    );
  }
}

// ── Options list (reused when no plan and in Change Plan section) ──────────

class _NutritionOptionsList extends StatelessWidget {
  final bool hasCoach;
  final Map<String, dynamic> myCoach;

  const _NutritionOptionsList({required this.hasCoach, required this.myCoach});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NeoOptionTile(
          title: 'SET MANUALLY',
          subtitle: 'Input your own macros and meals',
          icon: Icons.edit,
          color: NeoColors.lime,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const DesignNutritionManuallyScreen(),
            ),
          ),
        ),
        vGap(10),
        _NeoOptionTile(
          title: 'ASK AI COACH',
          subtitle: 'Generate a meal plan instantly',
          icon: Icons.smart_toy_outlined,
          color: NeoColors.magenta,
          onTap: () => showAiPlanGeneratorSheet(context, type: 'nutrition'),
        ),
        vGap(10),
        if (hasCoach) ...[
          _NeoOptionTile(
            title:
                'ASK ${(myCoach['name'] as String? ?? 'MY COACH').toUpperCase()}',
            subtitle: 'Request a nutrition plan from your coach',
            icon: Icons.sports_gymnastics,
            color: NeoColors.cyan,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MemberChatScreen(
                  coachName: myCoach['name'] as String? ?? 'Coach',
                  coachAvatarUrl: myCoach['avatar_url'] as String?,
                ),
              ),
            ),
          ),
          vGap(10),
        ],
        _NeoOptionTile(
          title: 'REAL COACH',
          subtitle: hasCoach
              ? 'Find another coach for nutrition'
              : 'Request a plan from your trainer',
          icon: Icons.person_outline,
          color: NeoColors.outline,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChooseCoachScreenNeo(source: 'eat'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NeoOptionTile extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _NeoOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0x66201F21),
              border: Border(left: BorderSide(color: color, width: 3)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22.r),
                hGap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: NeoTextStyles.headlineSm.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                      vGap(2),
                      Text(
                        subtitle,
                        style: NeoTextStyles.bodySm.copyWith(fontSize: 11.sp),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: NeoColors.outline,
                  size: 14.r,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  final int goal, consumed;
  const _CalorieRing({required this.goal, required this.consumed});

  @override
  Widget build(BuildContext context) {
    final left = (goal - consumed).clamp(0, goal);
    final pct = goal > 0 ? consumed / goal : 0.0;
    return SizedBox(
      width: 200.r,
      height: 200.r,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(200.r, 200.r),
            painter: _RingPainter(progress: pct.clamp(0.0, 1.0)),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CALORIES LEFT', style: NeoTextStyles.labelCaps),
              vGap(4),
              Text(
                '$left',
                style: GoogleFonts.anton(
                  fontSize: 40.sp,
                  color: NeoColors.cyan,
                  shadows: [
                    Shadow(
                      color: NeoColors.cyan.withValues(alpha: 0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              Text('$consumed / $goal kcal', style: NeoTextStyles.dataSm),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final trackPaint = Paint()
      ..color = const Color(0xFF353437)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.butt;
    final fillPaint = Paint()
      ..color = NeoColors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _MacrosRow extends StatelessWidget {
  final int protein, carbs, fat;
  const _MacrosRow({
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MacroCard(
            label: 'PROTEIN',
            value: protein,
            unit: 'g',
            color: NeoColors.lime,
          ),
        ),
        hGap(8),
        Expanded(
          child: _MacroCard(
            label: 'CARBS',
            value: carbs,
            unit: 'g',
            color: NeoColors.cyan,
          ),
        ),
        hGap(8),
        Expanded(
          child: _MacroCard(
            label: 'FAT',
            value: fat,
            unit: 'g',
            color: NeoColors.magenta,
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label, unit;
  final int value;
  final Color color;
  const _MacroCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: const Color(0x66201F21),
            border: Border(left: BorderSide(color: color, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: NeoTextStyles.labelCaps),
              vGap(4),
              Text(
                '$value$unit',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              vGap(6),
              ClipRect(
                child: LinearProgressIndicator(
                  value: 0.0,
                  minHeight: 2.h,
                  backgroundColor: NeoColors.surfaceTop,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final IconData icon;
  final String name;
  final int kcal;
  final Color color;
  const _MealCard({
    required this.icon,
    required this.name,
    required this.kcal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: const BoxDecoration(
              color: Color(0x66201F21),
              border: Border(bottom: BorderSide(color: Color(0x2600DCE6))),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(icon, color: color, size: 20.r),
                ),
                hGap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: NeoTextStyles.headlineSm),
                      Text(
                        kcal > 0 ? '$kcal kcal' : 'No items logged',
                        style: NeoTextStyles.bodySm,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => showFoodDialog(context),
                  icon: Icon(Icons.add, color: NeoColors.cyan, size: 20.r),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoPlan extends StatelessWidget {
  final bool hasCoach;
  final Map<String, dynamic> myCoach;
  const _NoPlan({required this.hasCoach, required this.myCoach});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, color: NeoColors.cyan, size: 48.r),
            vGap(16),
            Text(
              'NO NUTRITION PLAN',
              style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan),
            ),
            vGap(8),
            Text(
              'Set macros manually, ask AI, or get a plan from your coach',
              style: NeoTextStyles.bodySm,
              textAlign: TextAlign.center,
            ),
            vGap(20),
            _NutritionOptionsList(hasCoach: hasCoach, myCoach: myCoach),
          ],
        ),
      ),
    );
  }
}
