import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';

class EatTabNeo extends StatelessWidget {
  const EatTabNeo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final cubit = context.read<MemberCubit>();
        final plan = cubit.nutritionPlan;

        if (plan == null) {
          return _NoPlan();
        }

        final calories = (plan['daily_calories'] as num?)?.toInt() ?? 2000;
        final protein = (plan['protein_g'] as num?)?.toInt() ?? 0;
        final carbs = (plan['carbs_g'] as num?)?.toInt() ?? 0;
        final fat = (plan['fat_g'] as num?)?.toInt() ?? 0;
        final meals = (plan['meals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        const consumed = 0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 80.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NUTRITION', style: NeoTextStyles.headlineLg.copyWith(color: NeoColors.cyan)),
              vGap(4),
              Text('DAILY FUEL LOG', style: NeoTextStyles.labelCaps),
              vGap(20),
              Center(child: _CalorieRing(goal: calories, consumed: consumed)),
              vGap(20),
              _MacrosRow(protein: protein, carbs: carbs, fat: fat),
              vGap(20),
              Row(children: [
                Container(width: 3.w, height: 16.h, color: NeoColors.cyan),
                hGap(8),
                Text("TODAY'S LOG", style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
              ]),
              vGap(12),
              if (meals.isEmpty)
                ...[
                  _MealCard(icon: Icons.wb_sunny_outlined, name: 'BREAKFAST', kcal: 0, color: NeoColors.lime),
                  _MealCard(icon: Icons.lunch_dining, name: 'LUNCH', kcal: 0, color: NeoColors.cyan),
                  _MealCard(icon: Icons.dinner_dining, name: 'DINNER', kcal: 0, color: NeoColors.magenta),
                  _MealCard(icon: Icons.apple, name: 'SNACKS', kcal: 0, color: NeoColors.lime),
                ]
              else
                ...meals.map((m) => _MealCard(
                      icon: Icons.restaurant,
                      name: (m['name'] as String? ?? 'MEAL').toUpperCase(),
                      kcal: (m['calories'] as num?)?.toInt() ?? 0,
                      color: NeoColors.cyan,
                    )),
              vGap(80.h),
            ],
          ),
        );
      },
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
              Text('$left', style: GoogleFonts.anton(
                fontSize: 40.sp,
                color: NeoColors.cyan,
                shadows: [Shadow(color: NeoColors.cyan.withValues(alpha: 0.6), blurRadius: 12)],
              )),
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
  const _MacrosRow({required this.protein, required this.carbs, required this.fat});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MacroCard(label: 'PROTEIN', value: protein, unit: 'g', color: NeoColors.lime)),
        hGap(8),
        Expanded(child: _MacroCard(label: 'CARBS', value: carbs, unit: 'g', color: NeoColors.cyan)),
        hGap(8),
        Expanded(child: _MacroCard(label: 'FAT', value: fat, unit: 'g', color: NeoColors.magenta)),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label, unit;
  final int value;
  final Color color;
  const _MacroCard({required this.label, required this.value, required this.unit, required this.color});

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
              Text('$value$unit', style: GoogleFonts.jetBrainsMono(
                fontSize: 20.sp, fontWeight: FontWeight.w700, color: color,
              )),
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
  const _MealCard({required this.icon, required this.name, required this.kcal, required this.color});

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
                      Text(kcal > 0 ? '$kcal kcal' : 'No items logged', style: NeoTextStyles.bodySm),
                    ],
                  ),
                ),
                Icon(Icons.add, color: NeoColors.cyan, size: 20.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoPlan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, color: NeoColors.cyan, size: 48.r),
          vGap(16),
          Text('NO NUTRITION PLAN', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
          vGap(8),
          Text('Contact your coach to get a nutrition plan', style: NeoTextStyles.bodySm, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
