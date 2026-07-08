import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/cubit/health/health_cubit.dart';
import 'package:gym_app/core/services/ai_consent.dart';
import 'package:gym_app/core/services/health_service.dart';
import 'package:gym_app/core/theme/app_colors.dart';

import '../ai/chat_bubble.dart';
import '../ai/message_input.dart';
import '../ai/suggested_prompts.dart';
import '../ai/models/ai_member_context.dart';
import 'ai_abb_bar.dart';
import 'manager/ai_cubit.dart';
import '../data/repositories/member_repository.dart';
import '../home/manager/member_cubit.dart';
import '../home/manager/member_state.dart';
import '../inbody/models/inbody_model.dart';

class AiTab extends StatefulWidget {
  const AiTab({super.key});

  @override
  State<AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<AiTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AiAssistantCubit _cubit;
  InBodyModel? _latestInBody;

  @override
  void initState() {
    super.initState();
    _cubit = AiAssistantCubit();
    _loadInBody();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInBody() async {
    try {
      final records = await MemberRepository.getInBodyRecords();
      if (records.isNotEmpty && mounted) {
        setState(() {
          _latestInBody =
              InBodyModel.fromJson(records.first as Map<String, dynamic>);
        });
      }
    } catch (_) {}
  }

  AiMemberContext _buildContext(MemberCubit memberCubit, HealthState healthState) {
    final ms = memberCubit.state;
    HealthSnapshot? snapshot;
    if (healthState is HealthLoaded) snapshot = healthState.snapshot;
    return AiMemberContext(
      member:          ms is MemberLoaded ? ms.member : null,
      latestInBody:    _latestInBody,
      workoutPlan:     memberCubit.workoutPlan,
      nutritionPlan:   memberCubit.nutritionPlan,
      weekCheckIns:    memberCubit.weekCheckIns,
      healthSnapshot:  snapshot,
    );
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    if (!await AiConsent.ensure(context)) return;
    if (!mounted) return;
    _controller.clear();
    _cubit.sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final memberCubit  = context.watch<MemberCubit>();
    final healthState  = context.watch<HealthCubit>().state;
    final aiContext    = _buildContext(memberCubit, healthState);

    // Update cubit context every build (member / health data may have just loaded)
    _cubit.updateContext(aiContext);

    return BlocProvider.value(
      value: _cubit,
      child: Column(
        children: [
          const AiAbbBar(),
          Expanded(
            child: BlocConsumer<AiAssistantCubit, AiChatState>(
              listener: (context, state) => _scrollToBottom(),
              builder: (context, chatState) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 12),
                  itemCount: chatState.messages.length,
                  itemBuilder: (_, i) =>
                      ChatBubble(message: chatState.messages[i]),
                );
              },
            ),
          ),
          BlocBuilder<AiAssistantCubit, AiChatState>(
            builder: (context, chatState) {
              return SuggestedPrompts(
                prompts: aiContext.suggestedPrompts,
                onTap: _send,
              );
            },
          ),
          BlocBuilder<AiAssistantCubit, AiChatState>(
            builder: (context, chatState) {
              return MessageInput(
                controller: _controller,
                onSend: () => _send(_controller.text),
                hasInBody: _latestInBody != null,
                inBodyAttached: chatState.inBodyAttached,
                onToggleInBody: () {
                  if (_latestInBody != null) {
                    context.read<AiAssistantCubit>().toggleInBody();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'No InBody scan yet — add one in the InBody tab first',
                        ),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'Got it',
                          textColor: AppColors.teal,
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
