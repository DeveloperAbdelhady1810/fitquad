
import 'package:flutter/material.dart';

import '../../../../core/enums/messages_tab.dart';
import '../data/chat_model.dart';

@immutable
abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final MessagesTab selectedTab;
  final List<CoachChatMessage> filteredChats;

  MessagesLoaded({
    required this.selectedTab,
    required this.filteredChats,
  });
}
