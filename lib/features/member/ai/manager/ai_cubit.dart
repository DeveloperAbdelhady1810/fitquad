import 'package:bloc/bloc.dart';
import 'package:gym_app/core/services/gemini_service.dart';

import 'package:gym_app/features/member/data/models/message_model.dart';

class AiAssistantCubit extends Cubit<List<ChatMessage>> {
  AiAssistantCubit()
      : super([
          ChatMessage(
            text:
                "Hello! I'm your FitQuad AI Coach powered by Gemini. I can help you build workout plans, plan your nutrition, or answer any fitness question. What would you like to do today?",
            isUser: false,
          ),
        ]);

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    emit([...state, ChatMessage(text: text, isUser: true)]);
    emit([...state, ChatMessage(text: '', isUser: false, isTyping: true)]);

    try {
      final reply = await GeminiService.sendMessage(text);
      emit([
        ...state.where((m) => !m.isTyping),
        ChatMessage(text: reply, isUser: false),
      ]);
    } catch (e) {
      emit([
        ...state.where((m) => !m.isTyping),
        ChatMessage(
          text: "Sorry, I couldn't connect right now. Please check your internet and try again.",
          isUser: false,
        ),
      ]);
    }
  }

  void clearChat() {
    GeminiService.clearHistory();
    emit([
      ChatMessage(
        text:
            "Hello! I'm your FitQuad AI Coach powered by Gemini. I can help you build workout plans, plan your nutrition, or answer any fitness question. What would you like to do today?",
        isUser: false,
      ),
    ]);
  }
}
