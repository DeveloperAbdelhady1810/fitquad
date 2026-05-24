import 'package:bloc/bloc.dart';

import '../../../../core/enums/messages_tab.dart';
import '../../../coach/data/repositories/coach_repository.dart';
import '../data/chat_model.dart';
import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit() : super(MessagesInitial()) {
    loadMessages();
  }

  List<CoachChatMessage> _allChats = [];
  MessagesTab currentTab = MessagesTab.all;

  Future<void> loadMessages() async {
    try {
      final data = await CoachRepository.getMessages();
      _allChats = data
          .map((j) => CoachChatMessage.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Keep empty list on error
    }
    changeTab(currentTab);
  }

  void changeTab(MessagesTab tab) {
    currentTab = tab;

    final result = switch (tab) {
      MessagesTab.members =>
        _allChats.where((e) => e.type == MessageType.member).toList(),
      MessagesTab.system =>
        _allChats.where((e) => e.type == MessageType.system).toList(),
      MessagesTab.all => _allChats,
    };

    emit(MessagesLoaded(selectedTab: tab, filteredChats: result));
  }
}
