import 'package:bloc/bloc.dart';
import 'package:gym_app/features/member/ai/models/ai_member_context.dart';
import 'package:gym_app/features/member/data/models/message_model.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';

class AiChatState {
  final List<ChatMessage> messages;
  final bool inBodyAttached;

  const AiChatState({required this.messages, this.inBodyAttached = false});

  AiChatState copyWith({List<ChatMessage>? messages, bool? inBodyAttached}) =>
      AiChatState(
        messages: messages ?? this.messages,
        inBodyAttached: inBodyAttached ?? this.inBodyAttached,
      );
}

class AiAssistantCubit extends Cubit<AiChatState> {
  AiAssistantCubit()
      : super(const AiChatState(messages: []));

  AiMemberContext? _context;
  bool _greetingSet = false;

  /// Called from AiTab on every build once member data is available.
  /// Updates stored context for subsequent sends; sets greeting on first call
  /// with a real member.
  void updateContext(AiMemberContext ctx) {
    _context = ctx;
    if (!_greetingSet && ctx.member != null) {
      _greetingSet = true;
      emit(AiChatState(messages: [
        ChatMessage(text: ctx.greetingMessage(), isUser: false),
      ]));
    } else if (!_greetingSet && state.messages.isEmpty) {
      // Generic greeting while member is still loading
      emit(AiChatState(messages: [
        ChatMessage(
          text: "Hello! 👋 I'm your **FitQuad AI Coach**, powered by Gemini.\n\n"
              "Loading your profile…",
          isUser: false,
        ),
      ]));
      // Don't set _greetingSet yet — will be replaced once member loads
    }
  }

  void toggleInBody() {
    emit(state.copyWith(inBodyAttached: !state.inBodyAttached));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final wasAttached = state.inBodyAttached;
    final ctx = _context ?? const AiMemberContext();

    emit(state.copyWith(messages: [
      ...state.messages,
      ChatMessage(
        text: text,
        isUser: true,
        inBodyAttached: wasAttached,
      ),
      ChatMessage(text: '', isUser: false, isTyping: true),
    ]));

    try {
      final contextPrefix =
          ctx.buildSystemPrompt(includeInBody: wasAttached);
      final enriched = '$contextPrefix\n\nMember says: $text';
      final reply = await MemberRepository.sendAiMessage(enriched);

      emit(state.copyWith(messages: [
        ...state.messages.where((m) => !m.isTyping),
        ChatMessage(text: reply, isUser: false),
      ]));
    } catch (_) {
      emit(state.copyWith(messages: [
        ...state.messages.where((m) => !m.isTyping),
        const ChatMessage(
          text:
              "I couldn't connect right now. Please check your internet and try again.",
          isUser: false,
        ),
      ]));
    }
  }

  void clearChat() {
    _greetingSet = false;
    final ctx = _context;
    if (ctx != null && ctx.member != null) {
      _greetingSet = true;
      emit(AiChatState(messages: [
        ChatMessage(text: ctx.greetingMessage(), isUser: false),
      ]));
    } else {
      emit(const AiChatState(messages: []));
    }
  }
}
