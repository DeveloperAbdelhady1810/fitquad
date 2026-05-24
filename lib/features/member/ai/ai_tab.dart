import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../generated/l10n.dart';
import '../ai/chat_bubble.dart';
import '../ai/message_input.dart';
import '../ai/suggested_prompts.dart';
import '../data/models/message_model.dart';
import 'ai_abb_bar.dart';
import 'manager/ai_cubit.dart';

class AiTab extends StatefulWidget {
  const AiTab({super.key});

  @override
  State<AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<AiTab> {
  final TextEditingController _controller = TextEditingController();


  late AiAssistantCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = AiAssistantCubit();
  }

  void _sendMessage(String text) {
    if (text.isEmpty) return;
    _controller.clear();
    _cubit.sendMessage(text);
  }
  @override
  Widget build(BuildContext context) {
    final s =S.of(context);
    final List<String> prompts = [
      s.create_new_training_plan,
      s.adjust_my_workout_day,
      s.i_want_to_lose_fat,
      s.make_nutrition_plan
    ];
    return BlocProvider.value(
      value: _cubit,
      child: Column(
        children: [
          AiAbbBar(),
          Expanded(
            child: BlocBuilder<AiAssistantCubit, List<ChatMessage>>(
              builder: (context, messages) {
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          SuggestedPrompts(
            prompts: prompts,
            onTap: _sendMessage,
          ),
          MessageInput(controller: _controller, onSend: () => _sendMessage(_controller.text)),
        ],
      )
    );
  }
}
