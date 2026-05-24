import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';

import '../../../../core/enums/messages_tab.dart';
import '../../home/ui/widgets/message_tile.dart';
import '../manager/messages_cubit.dart';
import '../manager/messages_state.dart';

class CoachChatTab extends StatelessWidget {
  const CoachChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          CustomTabBar(
            onTap: (index) {
              final cubit = context.read<MessagesCubit>();

              if (index == 0) cubit.changeTab(MessagesTab.all);
              if (index == 1) cubit.changeTab(MessagesTab.members);
              if (index == 2) cubit.changeTab(MessagesTab.system);
            },
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Members'),
              Tab(text: 'System'),
            ],
          ),

          Expanded(
            child: BlocBuilder<MessagesCubit, MessagesState>(
              builder: (context, state) {
                if (state is MessagesLoaded) {
                  return ListView.builder(
                    itemCount: state.filteredChats.length,
                    itemBuilder: (context, index) {
                      final item = state.filteredChats[index];

                      return MessageTile(
                        item: item,
                        onTap: () {
                          if (item.type == MessageType.system) return;

                       //   context.push('/chat', extra: item);
                        },
                      );
                    },
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
