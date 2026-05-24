
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/coach/home/ui/widgets/home_tab.dart';


import '../../../../../core/theme/app_colors.dart';


import '../../../../member/home/manager/bottom_nav_bar_cubit.dart';
import '../../../calender/widgets/calender_tab.dart';
import '../../../chat/widgets/coach_chat_tab.dart';
import '../../../members/widgets/members_tab.dart';
import '../../../profile/widgets/profile_tab.dart';
import '../widgets/coach_bottom_nav_bar_view_body.dart';




class CoachBottomNavBarView extends StatefulWidget {
  const CoachBottomNavBarView({super.key});
  static const String routeName = '/coach-nav';

  @override
  State<CoachBottomNavBarView> createState() => CoachBottomNavBarViewState();
}

class CoachBottomNavBarViewState extends State<CoachBottomNavBarView> {
  @override
  Widget build(BuildContext context) {
    List<Widget> homeBodies = [
      HomeTab(),
      MembersTab(),
      CalenderTab(),
      CoachChatTab(),
      CoachProfileTab(),
    ];

    return BlocProvider(
      create: (_) => BottomNavBarCubit(),
      child: SafeArea(
        child: GestureDetector(
          onTap: () =>FocusScope.of(context).unfocus(),
          child: Scaffold(
           appBar: AppBar(
             toolbarHeight: 80,
             title: ListTile(
               title: Text('Hi Ahmed' , style: AppTextStyles.font14WhiteRegular,),
               subtitle: Text('Welcome to glance' , style: AppTextStyles.font14GreyRegular,),
             ),
             backgroundColor: AppColors.primary,
             leading: Padding(
               padding: const EdgeInsets.symmetric(horizontal: 5),
               child: CircleAvatar(
                 child: Icon(Icons.person),
               ),
             ),
           ),
            backgroundColor: AppColors.primary,
            extendBody: false,
            body: BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
              builder: (context, state) {
                final cubit = context.read<BottomNavBarCubit>();
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: homeBodies[cubit.currentIndex],
                );
              },
            ),
            bottomNavigationBar: CoachBottomNavBarViewBody(),
          ),
        ),
      ),
    );
  }
}
