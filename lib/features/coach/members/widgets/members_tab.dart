import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/enums/member_type.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';

import '../../../../core/widgets/search_text_feild.dart';
import '../../home/manager/coach_cubit.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({super.key});

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  late TextEditingController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          SearchTextField(controller: controller, hintText: 'search'),
          CustomTabBar(
            isScrollable: true,
            isSecondary: true,
            tabs: MemberType.values
                .map((type) => Tab(text: type.label(context)))
                .toList(),
            onTap: (index) {
              final cubit = context.read<CoachCubit>();
              final type = MemberType.values[index];

              if (type == MemberType.all) {
                cubit.filterMembers(null);
              } else {
                cubit.filterMembers(type);
              }
            },
          ),
          BlocBuilder<CoachCubit, CoachState>(
            builder: (context, state) {
              if (state is CoachesLoaded) {
                final members = state.filteredMembers;

                return Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (_, index) {
                      return ListTile(
                        title: Text(members[index].name??''),
                        subtitle: Text(members[index].type?.label(context)??''),
                      );
                    },
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          )


        ],
      ),
    );
  }
}
