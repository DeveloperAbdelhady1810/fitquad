import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/member/ai/ui/ai_plan_prompt_sheet.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/home/ui/views/workout_active_screen_neo.dart';
import 'package:gym_app/features/member/home/ui/widgets/choose_coach_screen_neo.dart';
import 'package:gym_app/features/member/partner_gyms/ui/partner_gyms_screen_neo.dart';

class TrainTabNeo extends StatefulWidget {
  const TrainTabNeo({super.key});

  @override
  State<TrainTabNeo> createState() => _TrainTabNeoState();
}

class _TrainTabNeoState extends State<TrainTabNeo> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final cubit = context.read<MemberCubit>();
        final checkIns = cubit.weekCheckIns;
        final plan = cubit.workoutPlan;
        final days = (plan?['days'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TRAINING', style: NeoTextStyles.headlineLg.copyWith(color: NeoColors.cyan)),
                  vGap(4),
                  Text('WEEKLY PERFORMANCE', style: NeoTextStyles.labelCaps),
                  vGap(16),
                  _WeekChart(checkIns: checkIns),
                  vGap(20),
                  if (plan != null) ...[
                    _PlanCard(plan: plan),
                    vGap(16),
                    Row(children: [
                      Container(width: 3.w, height: 18.h, color: NeoColors.cyan),
                      hGap(8),
                      Text('TRAINING SPLIT', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                    ]),
                    vGap(12),
                    ...days.asMap().entries.map((e) => _DayCard(
                          index: e.key,
                          day: e.value,
                          expanded: _expanded.contains(e.key),
                          onToggle: () => setState(() {
                            if (_expanded.contains(e.key)) {
                              _expanded.remove(e.key);
                            } else {
                              _expanded.add(e.key);
                            }
                          }),
                        )),
                    vGap(10),
                    _NeoBtn(
                      label: 'ASK AI COACH',
                      icon: Icons.smart_toy_outlined,
                      color: NeoColors.magenta,
                      onTap: () => showAiPlanGeneratorSheet(context, type: 'workout'),
                    ),
                    vGap(10),
                    Row(
                      children: [
                        Expanded(
                          child: _NeoBtn(
                            label: 'FIND A COACH',
                            icon: Icons.person_search,
                            color: NeoColors.cyan,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const ChooseCoachScreenNeo(),
                            )),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _NeoBtn(
                            label: 'BROWSE GYMS',
                            icon: Icons.storefront_outlined,
                            color: NeoColors.lime,
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const PartnerGymsScreenNeo(),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    _NoPlanCard(),
                ],
              ),
            ),
            if (plan != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _StartButton(plan: plan),
              ),
          ],
        );
      },
    );
  }
}

class _WeekChart extends StatelessWidget {
  final List<double> checkIns;
  const _WeekChart({required this.checkIns});

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxVal = checkIns.isEmpty ? 1.0 : (checkIns.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity));
    return _NeoGlassCard(
      padding: EdgeInsets.all(16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final val = i < checkIns.length ? checkIns[i] : 0.0;
          final pct = val / maxVal;
          final active = val > 0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                children: [
                  Container(
                    height: 60.h * pct.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      color: active ? NeoColors.lime : NeoColors.surfaceTop,
                      boxShadow: active ? [BoxShadow(color: NeoColors.lime.withValues(alpha: 0.4), blurRadius: 8)] : [],
                    ),
                  ),
                  vGap(4),
                  Text(days[i], style: NeoTextStyles.labelCaps),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final title = (plan['title'] as String? ?? 'WORKOUT PLAN').toUpperCase();
    final desc = plan['description'] as String? ?? '';
    return _NeoGlassCard(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(width: 4.w, height: 56.h, color: NeoColors.cyan),
          hGap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
                if (desc.isNotEmpty) ...[
                  vGap(4),
                  Text(desc, style: NeoTextStyles.bodySm, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> day;
  final bool expanded;
  final VoidCallback onToggle;
  const _DayCard({required this.index, required this.day, required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final name = (day['day_name'] as String? ?? 'Day ${index + 1}').toUpperCase();
    final exercises = (day['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: _NeoGlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(14.r),
                child: Row(
                  children: [
                    Text(name, style: NeoTextStyles.headlineSm.copyWith(
                      color: expanded ? NeoColors.cyan : NeoColors.onSurface,
                    )),
                    const Spacer(),
                    Text('${exercises.length} EXERCISES', style: NeoTextStyles.labelCaps),
                    hGap(8),
                    Icon(expanded ? Icons.expand_less : Icons.expand_more,
                        color: NeoColors.cyan, size: 18.r),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              Container(height: 1, color: NeoColors.cyan.withValues(alpha: 0.2)),
              ...exercises.map((ex) => _ExerciseRow(ex: ex)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Map<String, dynamic> ex;
  const _ExerciseRow({required this.ex});

  @override
  Widget build(BuildContext context) {
    final name = ex['name'] as String? ?? (ex['exercise'] as Map?)?['name'] as String? ?? 'Exercise';
    final sets = ex['sets']?.toString() ?? ex['pivot']?['sets']?.toString() ?? '—';
    final reps = ex['reps']?.toString() ?? ex['pivot']?['reps']?.toString() ?? '—';
    final rest = ex['rest_seconds']?.toString() ?? ex['pivot']?['rest_seconds']?.toString() ?? '—';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(child: Text(name, style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface))),
          _StatCell(label: 'SETS', value: sets),
          hGap(6),
          _StatCell(label: 'REPS', value: reps),
          hGap(6),
          _StatCell(label: 'REST', value: rest == '—' ? rest : '${rest}s'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: NeoColors.surfaceHigh,
        border: Border.all(color: NeoColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(value, style: NeoTextStyles.dataSm.copyWith(color: NeoColors.onSurface, fontSize: 11.sp)),
          Text(label, style: NeoTextStyles.labelCaps.copyWith(fontSize: 8.sp)),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final Map<String, dynamic> plan;
  const _StartButton({required this.plan});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final days = (plan['days'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final todayOrder = DateTime.now().weekday;
        Map<String, dynamic>? todayDay;
        try {
          todayDay = days.firstWhere((d) => (d['day_order'] as num?)?.toInt() == todayOrder);
        } catch (_) {
          if (days.isNotEmpty) todayDay = days.first;
        }
        final exercises = (todayDay?['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (exercises.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkoutActiveScreenNeo(
                exercises: exercises,
                planTitle: plan['title'] as String? ?? 'Workout',
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 8.h),
        height: 52.h,
        decoration: BoxDecoration(
          color: NeoColors.cyan,
          boxShadow: [BoxShadow(color: NeoColors.cyan.withValues(alpha: 0.4), blurRadius: 20)],
        ),
        child: Center(
          child: Text(
            'START WORKOUT',
            style: GoogleFonts.anton(fontSize: 16.sp, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _NoPlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _NeoGlassCard(
      padding: EdgeInsets.all(24.r),
      child: Column(
        children: [
          Icon(Icons.sports_gymnastics, color: NeoColors.cyan, size: 40.r),
          vGap(12),
          Text('NO PLAN ACTIVE', style: NeoTextStyles.headlineSm.copyWith(color: NeoColors.cyan)),
          vGap(6),
          Text('Ask AI, find a coach, or browse gyms to get started', style: NeoTextStyles.bodySm, textAlign: TextAlign.center),
          vGap(20),
          _NeoBtn(
            label: 'ASK AI COACH',
            icon: Icons.smart_toy_outlined,
            color: NeoColors.magenta,
            onTap: () => showAiPlanGeneratorSheet(context, type: 'workout'),
          ),
          vGap(10),
          Row(
            children: [
              Expanded(
                child: _NeoBtn(
                  label: 'FIND A COACH',
                  icon: Icons.person_search,
                  color: NeoColors.cyan,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ChooseCoachScreenNeo(),
                  )),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _NeoBtn(
                  label: 'BROWSE GYMS',
                  icon: Icons.storefront_outlined,
                  color: NeoColors.lime,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const PartnerGymsScreenNeo(),
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NeoBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _NeoBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.5)),
          color: color.withValues(alpha: 0.08),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.r),
            SizedBox(height: 4.h),
            Text(label, style: NeoTextStyles.labelCaps.copyWith(color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _NeoGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  const _NeoGlassCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x66201F21),
            border: Border.all(color: const Color(0x2600DCE6)),
          ),
          child: child,
        ),
      ),
    );
  }
}
