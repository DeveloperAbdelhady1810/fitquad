import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';
import 'package:intl/intl.dart';

class GeminiService {
  static const _apiKey = 'AIzaSyDY20jEm0uOCDg5F3PJRUANQeNzm2Bs6vo';

  static const _systemPrompt = '''
You are FitQuad AI Coach — a professional fitness and nutrition assistant built into the FitQuad gym app.

Your role:
- Help members build personalised workout and nutrition plans
- Answer questions about exercises, form, recovery, and progression
- Provide motivation and accountability
- Adapt plans based on the member's goals (fat loss, muscle gain, endurance, general fitness)
- Give practical, evidence-based advice

Guidelines:
- Keep replies concise and actionable (3–5 sentences max unless a plan is requested)
- Use bullet points for plans and exercise lists
- Always be encouraging and positive
- If asked about medical conditions, recommend consulting a doctor
- Do not recommend unsafe practices or extreme diets
- If the user asks about something unrelated to fitness or nutrition, politely redirect them
''';

  static final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: _apiKey,
    systemInstruction: Content.system(_systemPrompt),
    generationConfig: GenerationConfig(
      temperature: 0.7,
      maxOutputTokens: 512,
    ),
  );

  static final List<Content> _history = [];

  static Future<String> sendMessage(String userMessage) async {
    final userContent = Content.text(userMessage);
    _history.add(userContent);

    final chat = _model.startChat(history: _history.length > 1
        ? _history.sublist(0, _history.length - 1)
        : []);

    final response = await chat.sendMessage(userContent);
    final reply = response.text ?? 'Sorry, I could not generate a response.';

    _history.add(Content.model([TextPart(reply)]));
    return reply;
  }

  static void clearHistory() => _history.clear();

  static Future<String> sendMessageWithInBody(
      String userMessage, InBodyModel inBody) async {
    final dateLabel = DateFormat('MMM d, yyyy')
        .format(inBody.recordedAt ?? DateTime.now());
    final lines = <String>[
      '[Member InBody Data — $dateLabel]',
      if (inBody.weight != null) '• Weight: ${inBody.weight} kg',
      if (inBody.bodyFatPct != null) '• Body Fat: ${inBody.bodyFatPct}%',
      if (inBody.muscleMass != null)
        '• Muscle Mass: ${inBody.muscleMass} kg',
      if (inBody.bmi != null) '• BMI: ${inBody.bmi}',
      if (inBody.bmr != null) '• BMR: ${inBody.bmr} kcal',
      if (inBody.visceralFat != null)
        '• Visceral Fat: ${inBody.visceralFat}',
      if (inBody.inbodyScore != null)
        '• InBody Score: ${inBody.inbodyScore}/100',
      '',
      'Use this data to give personalized advice.',
    ];
    final context = lines.join('\n');
    return sendMessage('$context\n\nMember question: $userMessage');
  }
}
