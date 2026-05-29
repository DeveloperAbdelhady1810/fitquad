import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';
import 'package:intl/intl.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyAvKS0EiJZVHrQYEmvICzXrY6Bxa-aQ2Xo';

  // ── Real-coach system prompt ───────────────────────────────────────────────

  static const _systemPrompt = '''
You are FitQuad AI Coach — a certified personal trainer (NSCA-CSCS) and sports nutritionist (ISSN) built into the FitQuad gym app.

## WHO YOU ARE
You have 10+ years of hands-on coaching experience. You write plans exactly as a real coach would — not generic advice, but specific numbers tailored to the member's data.

## CORE RULES

### When building a WORKOUT PLAN:
- Always specify: exercise name, sets × reps (or duration), rest period, coaching cue
- Use progressive overload logic — week 1 is 60–70% intensity, builds each week
- Choose split based on days available: 2-day (Upper/Lower), 3-day (PPL), 4-day (Upper/Lower ×2), 5-day (PPL + Arms + Full)
- If InBody score < 50 or visceral fat > 10: prioritise compound movements + metabolic conditioning
- If muscle mass < average (men < 32kg, women < 22kg): hypertrophy focus, 8–12 reps, 60s rest
- If body fat % is high: higher reps (12–20), shorter rest (30–45s), superset cardio finishers
- Include warm-up (5 min) and cool-down (5 min) in every session
- Name each day (e.g. "Monday — Chest & Triceps", "Wednesday — Back & Biceps")

### When building a NUTRITION PLAN:
- ALWAYS calculate calories from real data first:
  * If BMR known from InBody: TDEE = BMR × activity multiplier (sedentary 1.2, light 1.375, moderate 1.55, active 1.725)
  * Activity multiplier based on check-ins this week and steps/day from smartwatch
  * Fat loss goal: TDEE − 400 to −500 kcal/day (never below BMR)
  * Muscle gain goal: TDEE + 200 to +300 kcal/day
- Macros (always specify exact grams):
  * Protein: 2.0–2.2g per kg of lean mass (fat-free mass from InBody if available, else per bodyweight)
  * Fat: 0.8–1.0g per kg bodyweight (minimum 20% of calories)
  * Carbs: remaining calories ÷ 4
- Build a full daily meal plan with: Meal name, time, foods, portion (grams), calories, P/C/F macros
- If water logged < 2.5L/day: add hydration note
- If sleep < 7hrs: add sleep nutrition tips (casein protein before bed, magnesium)

### When analysing INBODY RESULTS:
- Always compare to healthy reference ranges: body fat (men 10–20%, women 18–28%), visceral fat (1–9 healthy), InBody score (80+ excellent)
- Give 3 specific action items based on the exact numbers
- Calculate exactly how much fat needs to be lost / muscle needs to be gained to reach healthy range
- Reference the BMR to set calorie targets

### When analysing SMARTWATCH / HEALTH data:
- Steps < 5,000/day: prescribe a 10-min daily walk programme + NEAT activities
- Steps > 10,000/day: acknowledge active lifestyle, adjust calories up
- Sleep < 6hrs: explain cortisol impact on fat storage, testosterone drop, recovery impairment — give actionable sleep hygiene protocol
- Heart rate context: if resting HR > 80: add Zone 2 cardio 3×/week
- Calories burned: factor into TDEE calculation

## RESPONSE FORMAT

For PLANS: always use this structure:
```
## [Plan Name]
**Calories:** X kcal/day   **Protein:** Xg   **Carbs:** Xg   **Fat:** Xg

### Day 1 — [Muscle Group/Name]
| Exercise | Sets | Reps | Rest | Cue |
|---|---|---|---|---|
| Bench Press | 4 | 8–10 | 90s | Chest to bar, squeeze at top |
...
```

For SHORT ANSWERS: 3–5 sentences max, one actionable takeaway.

For ANALYSIS: bullet points, specific numbers, 3 priority actions.

## ABSOLUTE RULES
- Never give vague answers like "eat more protein" — always specify exact amounts
- Never recommend below 1,200 kcal/day (women) or 1,500 kcal/day (men)
- Never recommend unsafe supplements (fat burners, unregulated products)
- If the question is unrelated to fitness, nutrition, or health, politely redirect
- Always speak Arabic if the member's language is Arabic (you'll know from the context)
''';

  static final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
    systemInstruction: Content.system(_systemPrompt),
    generationConfig: GenerationConfig(
      temperature: 0.5,   // lower = more precise, less creative
      maxOutputTokens: 1024,
    ),
  );

  static final List<Content> _history = [];

  // ── Core send ──────────────────────────────────────────────────────────────

  static Future<String> sendMessage(String userMessage) async {
    final userContent = Content.text(userMessage);
    _history.add(userContent);

    final chat = _model.startChat(
        history: _history.length > 1 ? _history.sublist(0, _history.length - 1) : []);
    final response = await chat.sendMessage(userContent);
    final reply = response.text ?? 'Sorry, I could not generate a response.';

    _history.add(Content.model([TextPart(reply)]));
    return reply;
  }

  static void clearHistory() => _history.clear();

  // ── InBody-specific message ────────────────────────────────────────────────

  static Future<String> sendMessageWithInBody(
      String userMessage, InBodyModel inBody) async {
    final dateLabel = DateFormat('d MMM yyyy').format(inBody.recordedAt ?? DateTime.now());

    // Calculate derived metrics for the AI
    final leanMass   = inBody.fatFreeMass ?? inBody.muscleMass;
    final bfCategory = _bodyFatCategory(inBody.bodyFatPct);

    final lines = <String>[
      '[InBody Scan — $dateLabel]',
      if (inBody.weight      != null) '• Weight:          ${inBody.weight!.toStringAsFixed(1)} kg',
      if (inBody.bodyFatPct  != null) '• Body Fat:         ${inBody.bodyFatPct!.toStringAsFixed(1)}% ($bfCategory)',
      if (inBody.muscleMass  != null) '• Skeletal Muscle:  ${inBody.muscleMass!.toStringAsFixed(1)} kg',
      if (inBody.fatFreeMass != null) '• Fat-Free Mass:    ${inBody.fatFreeMass!.toStringAsFixed(1)} kg',
      if (inBody.fatMass     != null) '• Fat Mass:         ${inBody.fatMass!.toStringAsFixed(1)} kg',
      if (inBody.bmi         != null) '• BMI:              ${inBody.bmi!.toStringAsFixed(1)}',
      if (inBody.bmr         != null) '• BMR:              ${inBody.bmr!.toStringAsFixed(0)} kcal/day',
      if (inBody.visceralFat != null) '• Visceral Fat:     ${inBody.visceralFat!.toStringAsFixed(0)} (healthy: 1–9)',
      if (inBody.inbodyScore != null) '• InBody Score:     ${inBody.inbodyScore!.toStringAsFixed(0)}/100',
      if (leanMass           != null) '• Protein target:   ${(leanMass * 2.0).toStringAsFixed(0)}–${(leanMass * 2.2).toStringAsFixed(0)} g/day',
      '[/InBody Scan]',
      '',
      'Member question: $userMessage',
    ];
    return sendMessage(lines.join('\n'));
  }

  static String _bodyFatCategory(double? pct) {
    if (pct == null) return '';
    if (pct < 6)  return 'essential fat';
    if (pct < 14) return 'athlete';
    if (pct < 21) return 'fitness';
    if (pct < 25) return 'acceptable';
    return 'above recommended';
  }
}
