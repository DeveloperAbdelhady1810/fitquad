import 'package:gym_app/core/enums/member_type.dart';
import 'package:gym_app/features/member/data/models/member_model.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';
import 'package:intl/intl.dart';

class AiMemberContext {
  final MemberModel? member;
  final InBodyModel? latestInBody;
  final Map<String, dynamic>? workoutPlan;
  final Map<String, dynamic>? nutritionPlan;
  final List<double> weekCheckIns;

  const AiMemberContext({
    this.member,
    this.latestInBody,
    this.workoutPlan,
    this.nutritionPlan,
    this.weekCheckIns = const [],
  });

  bool get hasInBody => latestInBody != null;

  /// Builds the context prefix injected into every AI message.
  String buildSystemPrompt({bool includeInBody = false}) {
    final buf = StringBuffer();
    buf.writeln('[FITQUAD_MEMBER_CONTEXT — use this to personalise your response]');

    if (member != null) {
      final m = member!;
      if (m.name != null) buf.writeln('Member name: ${m.name}');
      buf.writeln('Fitness goal: ${_goalLabel(m.type)}');
      if (m.weight != null) buf.writeln('Current weight: ${m.weight!.toStringAsFixed(1)} kg');
      if (m.age != null) buf.writeln('Age: ${m.age!.toInt()} years');
      buf.writeln(
          'Streak: ${m.streakDays} days  |  Level: ${m.level}  |  XP: ${m.xpPoints} pts');
    }

    if (weekCheckIns.isNotEmpty) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final summary = List.generate(
        weekCheckIns.length.clamp(0, 7),
        (i) => '${days[i]}${weekCheckIns[i] > 0 ? "✓" : "✗"}',
      ).join('  ');
      buf.writeln('This week\'s gym check-ins: $summary');
    }

    if (workoutPlan != null) {
      final name = workoutPlan!['name'] as String? ?? 'Active Workout Plan';
      buf.writeln('Workout plan: $name (active)');
    }

    if (nutritionPlan != null) {
      final kcal =
          nutritionPlan!['daily_calories'] ?? nutritionPlan!['calories'];
      buf.writeln(
          'Nutrition plan: ${kcal != null ? "$kcal kcal / day" : "active"}');
    }

    if (includeInBody && latestInBody != null) {
      final ib = latestInBody!;
      final date = ib.recordedAt != null
          ? DateFormat('d MMM yyyy').format(ib.recordedAt!)
          : 'recent';
      buf.write('InBody scan ($date):');
      if (ib.weight != null) { buf.write(' Weight ${ib.weight!.toStringAsFixed(1)} kg'); }
      if (ib.bmi != null) { buf.write(' · BMI ${ib.bmi!.toStringAsFixed(1)}'); }
      if (ib.bodyFatPct != null) { buf.write(' · Body Fat ${ib.bodyFatPct!.toStringAsFixed(1)} %'); }
      if (ib.muscleMass != null) { buf.write(' · Muscle Mass ${ib.muscleMass!.toStringAsFixed(1)} kg'); }
      if (ib.fatMass != null) { buf.write(' · Fat Mass ${ib.fatMass!.toStringAsFixed(1)} kg'); }
      if (ib.visceralFat != null) { buf.write(' · Visceral Fat ${ib.visceralFat!.toStringAsFixed(0)}'); }
      if (ib.bmr != null) { buf.write(' · BMR ${ib.bmr!.toStringAsFixed(0)} kcal'); }
      if (ib.inbodyScore != null) { buf.write(' · InBody Score ${ib.inbodyScore!.toStringAsFixed(0)}/100'); }
      if (ib.fatFreeMass != null) { buf.write(' · Fat-Free Mass ${ib.fatFreeMass!.toStringAsFixed(1)} kg'); }
      if (ib.targetWeight != null) { buf.write(' · Target Weight ${ib.targetWeight!.toStringAsFixed(1)} kg'); }
      buf.writeln();
    }

    buf.writeln('[/FITQUAD_MEMBER_CONTEXT]');
    return buf.toString();
  }

  static String _goalLabel(MemberType? type) {
    switch (type) {
      case MemberType.loss:
        return 'Weight Loss & Fat Burning';
      case MemberType.fit:
        return 'Muscle Building & General Fitness';
      case MemberType.low:
        return 'Low Activity & Gentle Exercise';
      default:
        return 'General Fitness (getting started)';
    }
  }

  /// Personalised opening message based on goal.
  String greetingMessage() {
    final firstName = member?.name?.split(' ').first ?? 'there';
    switch (member?.type) {
      case MemberType.loss:
        return "Hi $firstName! 👋 I'm your **FitQuad AI Coach**, powered by Gemini.\n\n"
            "I can see your goal is **Weight Loss & Fat Burning** — let's make it happen! "
            "I have access to your activity streak, workout plan, and nutrition data.\n\n"
            "💡 Tap **Attach InBody** below to include your body-composition scan so I can give you data-driven, personalised advice.\n\n"
            "What would you like to work on today?";
      case MemberType.fit:
        return "Hi $firstName! 👋 I'm your **FitQuad AI Coach**, powered by Gemini.\n\n"
            "Your goal is **Muscle Building & Fitness** — let's get to work! I can build optimised training splits, calculate your exact protein targets, and analyse your progress.\n\n"
            "💡 Tap **Attach InBody** below to share your body-composition data for hyper-personalised recommendations.\n\n"
            "What would you like to work on today?";
      case MemberType.low:
        return "Hi $firstName! 👋 I'm your **FitQuad AI Coach**, powered by Gemini.\n\n"
            "I see you're on a **low-activity program** — every step counts! I'll keep recommendations gentle, sustainable, and easy to follow.\n\n"
            "💡 Tap **Attach InBody** below to include your health data for personalised guidance.\n\n"
            "What would you like to work on today? 🌱";
      default:
        return "Hi $firstName! 👋 I'm your **FitQuad AI Coach**, powered by Gemini.\n\n"
            "I'm here to build personalised workouts, nutrition plans, and help you track your progress. "
            "Tell me your goals and I'll create a plan tailored to you.\n\n"
            "💡 Tap **Attach InBody** to share your body-composition data for smarter advice.\n\n"
            "What would you like to work on today? 💪";
    }
  }

  /// Goal-driven suggested prompts shown as chips.
  List<String> get suggestedPrompts {
    switch (member?.type) {
      case MemberType.loss:
        return [
          'Build me a fat-loss meal plan',
          'How much protein do I need?',
          'Best cardio for fat burn',
          'Review my InBody results',
        ];
      case MemberType.fit:
        return [
          'Create a muscle-building split',
          'Optimal protein & calorie intake',
          'Best hypertrophy exercises',
          'Review my InBody results',
        ];
      case MemberType.low:
        return [
          'Gentle workout routine for me',
          'Low-calorie meal ideas',
          'How to improve my mobility',
          'Review my InBody results',
        ];
      default:
        return [
          'Where do I start as a beginner?',
          'Simple beginner meal plan',
          'Best first exercises for me',
          'Help me set my fitness goals',
        ];
    }
  }
}
