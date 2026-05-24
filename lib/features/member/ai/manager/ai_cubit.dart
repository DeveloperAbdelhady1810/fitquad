import 'package:bloc/bloc.dart';

import '../../../member/data/repositories/member_repository.dart';
import '../../data/models/message_model.dart';

class AiAssistantCubit extends Cubit<List<ChatMessage>> {
  AiAssistantCubit()
    : super([
        ChatMessage(
          text:
              "Hello! I'm your AI Coach. I can help you customize your training, build meal plans, or adjust your goals. What would you like to do today?",
          isUser: false,
        ),
      ]);

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    emit([...state, ChatMessage(text: text, isUser: true)]);
    emit([...state, ChatMessage(text: '', isUser: false, isTyping: true)]);

    try {
      final reply = await MemberRepository.sendAiMessage(text);
      emit([
        ...state.where((m) => !m.isTyping),
        ChatMessage(text: reply, isUser: false),
      ]);
    } catch (_) {
      emit([
        ...state.where((m) => !m.isTyping),
        ChatMessage(
          text: "Sorry, I couldn't connect to the AI right now. Please try again.",
          isUser: false,
        ),
      ]);
    }
  }
}
