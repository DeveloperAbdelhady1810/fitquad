import 'package:gym_app/core/enums/member_type.dart';
import 'package:gym_app/core/services/health_service.dart';
import 'package:gym_app/features/member/data/models/member_model.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';
import 'package:intl/intl.dart';

class AiMemberContext {
  final MemberModel? member;
  final InBodyModel? latestInBody;
  final Map<String, dynamic>? workoutPlan;
  final Map<String, dynamic>? nutritionPlan;
  final List<double> weekCheckIns;
  final HealthSnapshot? healthSnapshot; // today's smartwatch / Apple Health data

  const AiMemberContext({
    this.member,
    this.latestInBody,
    this.workoutPlan,
    this.nutritionPlan,
    this.weekCheckIns = const [],
    this.healthSnapshot,
  });

  bool get hasInBody => latestInBody != null;
  bool get hasHealth  => healthSnapshot != null &&
      (healthSnapshot!.steps > 0 || healthSnapshot!.sleepHrs > 0 ||
       healthSnapshot!.caloriesBurned > 0);

  // ── System prompt injected before every message ───────────────────────────

  String buildSystemPrompt({bool includeInBody = false}) {
    final buf = StringBuffer();
    buf.writeln('[FITQUAD_MEMBER_CONTEXT — use ALL of this data to personalise your response]');

    // ── Member basics ────────────────────────────────────────────────────────
    if (member != null) {
      final m = member!;
      buf.writeln('## Member Profile');
      if (m.name  != null) buf.writeln('Name:          ${m.name}');
      buf.writeln('Fitness goal:  ${_goalLabel(m.type)}');
      if (m.weight != null) buf.writeln('Body weight:   ${m.weight!.toStringAsFixed(1)} kg');
      if (m.age    != null) buf.writeln('Age:           ${m.age!.toInt()} yrs');
      buf.writeln('Level:         ${m.level}  |  Streak: ${m.streakDays} days  |  XP: ${m.xpPoints}');
      if (m.sleepHrs != null && m.sleepHrs! > 0) {
        buf.writeln('Logged sleep:  ${m.sleepHrs!.toStringAsFixed(1)} hrs/night');
      }
      if (m.waterL  != null && m.waterL! > 0) {
        buf.writeln('Logged water:  ${m.waterL!.toStringAsFixed(1)} L/day');
      }
    }

    // ── Gym attendance ────────────────────────────────────────────────────────
    if (weekCheckIns.isNotEmpty) {
      const days  = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
      final total = weekCheckIns.where((v) => v > 0).length;
      final row   = List.generate(weekCheckIns.length.clamp(0, 7),
          (i) => '${days[i]}:${weekCheckIns[i] > 0 ? "✓" : "✗"}').join('  ');
      buf.writeln('## Gym Attendance This Week ($total/7 days)');
      buf.writeln(row);
      // Derive activity multiplier
      final multiplier = total >= 5 ? 1.725 : total >= 3 ? 1.55 : total >= 1 ? 1.375 : 1.2;
      buf.writeln('Activity multiplier for TDEE: ×$multiplier');
    }

    // ── Smartwatch / Apple Health data ─────────────────────────────────────
    if (hasHealth) {
      final h = healthSnapshot!;
      buf.writeln('## Smartwatch / Health Data (today)');
      if (h.steps         > 0) buf.writeln('Steps:             ${_n(h.steps)}/day');
      if (h.caloriesBurned > 0) buf.writeln('Calories burned:   ${h.caloriesBurned} kcal');
      if (h.heartRateBpm  > 0) buf.writeln('Avg heart rate:    ${h.heartRateBpm} bpm');
      if (h.sleepHrs      > 0) buf.writeln('Sleep last night:  ${h.sleepHrs.toStringAsFixed(1)} hrs');

      // Flags the AI should act on
      if (h.steps < 5000)       buf.writeln('⚠ Very sedentary day — include NEAT activities in plan');
      if (h.sleepHrs > 0 && h.sleepHrs < 6) buf.writeln('⚠ Poor sleep — recovery is impaired; reduce intensity today');
      if (h.heartRateBpm > 80)  buf.writeln('⚠ Elevated resting HR — add Zone 2 cardio to programme');
    }

    // ── Active plans ─────────────────────────────────────────────────────────
    if (workoutPlan != null) {
      final title = workoutPlan!['title'] as String? ?? 'Active Workout Plan';
      final days  = (workoutPlan!['days'] as List?)?.length ?? 0;
      buf.writeln('## Current Workout Plan');
      buf.writeln('Title: $title  ($days training days/week)');
    }
    if (nutritionPlan != null) {
      final kcal    = nutritionPlan!['daily_calories'];
      final protein = nutritionPlan!['protein_g'];
      final carbs   = nutritionPlan!['carbs_g'];
      final fat     = nutritionPlan!['fat_g'];
      buf.writeln('## Current Nutrition Plan');
      if (kcal != null) buf.write('Calories: ${kcal} kcal');
      if (protein != null) buf.write('  Protein: ${protein}g');
      if (carbs   != null) buf.write('  Carbs: ${carbs}g');
      if (fat     != null) buf.write('  Fat: ${fat}g');
      buf.writeln();
    }

    // ── InBody scan (only when explicitly attached) ──────────────────────────
    if (includeInBody && latestInBody != null) {
      final ib  = latestInBody!;
      final dt  = ib.recordedAt != null
          ? DateFormat('d MMM yyyy').format(ib.recordedAt!) : 'recent';
      buf.writeln('## InBody Scan ($dt) — USE THESE FOR EXACT CALCULATIONS');

      if (ib.weight      != null) buf.writeln('Weight:          ${ib.weight!.toStringAsFixed(1)} kg');
      if (ib.bodyFatPct  != null) buf.writeln('Body Fat:        ${ib.bodyFatPct!.toStringAsFixed(1)}%  (healthy: men 10–20%, women 18–28%)');
      if (ib.muscleMass  != null) buf.writeln('Skeletal Muscle: ${ib.muscleMass!.toStringAsFixed(1)} kg');
      if (ib.fatFreeMass != null) buf.writeln('Fat-Free Mass:   ${ib.fatFreeMass!.toStringAsFixed(1)} kg');
      if (ib.fatMass     != null) buf.writeln('Fat Mass:        ${ib.fatMass!.toStringAsFixed(1)} kg');
      if (ib.bmi         != null) buf.writeln('BMI:             ${ib.bmi!.toStringAsFixed(1)}');
      if (ib.bmr         != null) buf.writeln('BMR:             ${ib.bmr!.toStringAsFixed(0)} kcal/day  ← USE THIS as calorie floor');
      if (ib.visceralFat != null) buf.writeln('Visceral Fat:    ${ib.visceralFat!.toStringAsFixed(0)}  (healthy: 1–9)');
      if (ib.inbodyScore != null) buf.writeln('InBody Score:    ${ib.inbodyScore!.toStringAsFixed(0)}/100');

      // Pre-calculate protein target for AI
      final leanMass = ib.fatFreeMass ?? ib.muscleMass;
      if (leanMass != null) {
        buf.writeln('→ Protein target: ${(leanMass * 2.0).toStringAsFixed(0)}–${(leanMass * 2.2).toStringAsFixed(0)} g/day  (2.0–2.2g per kg lean mass)');
      }
      // Pre-calculate fat loss target
      if (ib.bodyFatPct != null && ib.weight != null) {
        final member = this.member;
        final targetBf = (member?.type == MemberType.loss || member?.type == MemberType.fit) ? 15.0 : 20.0;
        if (ib.bodyFatPct! > targetBf) {
          final currentFat = ib.fatMass ?? (ib.weight! * ib.bodyFatPct! / 100);
          final targetFat  = ib.weight! * targetBf / 100;
          final tolose     = currentFat - targetFat;
          buf.writeln('→ Fat to lose to reach ${targetBf.toStringAsFixed(0)}% BF: ~${tolose.toStringAsFixed(1)} kg');
        }
      }
    }

    buf.writeln('[/FITQUAD_MEMBER_CONTEXT]');
    return buf.toString();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _n(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  static String _goalLabel(MemberType? type) => switch (type) {
    MemberType.loss => 'Weight Loss & Fat Burning',
    MemberType.fit  => 'Muscle Building & General Fitness',
    MemberType.low  => 'Low Activity & Gentle Exercise',
    _               => 'General Fitness (beginner)',
  };

  // ── Greeting ──────────────────────────────────────────────────────────────

  String greetingMessage() {
    final firstName = member?.name?.split(' ').first ?? 'there';
    final dataHint  = hasInBody
        ? '**Your InBody scan is loaded** — I can calculate your exact calorie targets and protein needs.'
        : '💡 Tap **Attach InBody** to share your body-composition scan for precise, data-driven plans.';
    final watchHint = hasHealth
        ? '**Your smartwatch data is connected** (${_n(healthSnapshot!.steps)} steps today, ${healthSnapshot!.sleepHrs.toStringAsFixed(1)}h sleep).'
        : '';

    return switch (member?.type) {
      MemberType.loss => '''Hi $firstName! 👋 I\'m your **FitQuad AI Coach**.

Your goal is **Weight Loss & Fat Burning**. Here\'s what I can do right now:
- Build a calorie-deficit nutrition plan with exact macros
- Design a fat-burning workout split (compound lifts + metabolic finishers)
- Analyse your InBody scan and tell you exactly how much fat to lose

$dataHint ${watchHint.isNotEmpty ? '\n$watchHint' : ''}

What would you like to work on?''',
      MemberType.fit => '''Hi $firstName! 👋 I\'m your **FitQuad AI Coach**.

Your goal is **Muscle Building**. I can:
- Calculate your exact protein target and calorie surplus
- Design a hypertrophy training split with progressive overload
- Analyse your muscle-to-fat ratio from InBody

$dataHint ${watchHint.isNotEmpty ? '\n$watchHint' : ''}

What would you like to work on?''',
      MemberType.low => '''Hi $firstName! 👋 I\'m your **FitQuad AI Coach**.

You\'re on a **gentle activity programme**. I\'ll keep everything sustainable:
- Low-impact workouts that build habits without burnout
- Anti-inflammatory, energy-boosting meal plans
- Recovery and sleep optimisation

$dataHint ${watchHint.isNotEmpty ? '\n$watchHint' : ''}

How can I help you today? 🌱''',
      _ => '''Hi $firstName! 👋 I\'m your **FitQuad AI Coach**.

Tell me your goals and I\'ll build a complete, data-driven plan — not generic advice, but specific numbers calculated for **your** body.

$dataHint ${watchHint.isNotEmpty ? '\n$watchHint' : ''}

What would you like to start with? 💪''',
    };
  }

  // ── Suggested prompts ─────────────────────────────────────────────────────

  List<String> get suggestedPrompts => switch (member?.type) {
    MemberType.loss => [
      hasInBody ? 'Build my fat-loss plan from my InBody' : 'Build me a fat-loss plan',
      'How many calories should I eat?',
      hasHealth  ? 'Analyse my smartwatch data' : 'Best cardio for fat burn',
      'What exercises burn the most fat?',
    ],
    MemberType.fit => [
      hasInBody ? 'Build my muscle-gain plan from my InBody' : 'Build a muscle-building split',
      hasInBody ? 'Calculate my exact protein target' : 'How much protein do I need?',
      hasHealth  ? 'Analyse my recovery data' : 'Best hypertrophy exercises',
      'Progressive overload plan for me',
    ],
    MemberType.low => [
      'Gentle weekly workout for me',
      'Anti-inflammatory meal plan',
      hasHealth ? 'Analyse my activity level' : 'How to move more daily',
      'Improve my sleep & recovery',
    ],
    _ => [
      'Where do I start as a beginner?',
      hasInBody ? 'Read my InBody results' : 'Simple beginner workout plan',
      'Easy meal plan for my goal',
      'Help me set fitness targets',
    ],
  };
}
