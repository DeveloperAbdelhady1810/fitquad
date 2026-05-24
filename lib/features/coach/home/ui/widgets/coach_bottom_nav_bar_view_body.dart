import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../../core/theme/app_colors.dart';
import '../../../../../generated/l10n.dart';
import '../../../../member/home/manager/bottom_nav_bar_cubit.dart';

class CoachBottomNavBarViewBody extends StatelessWidget {
  const CoachBottomNavBarViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
      builder: (context, state) {
        final cubit = context.read<BottomNavBarCubit>();
        final s=S.of(context);

        return BottomNavigationBar(
          showUnselectedLabels: true,
          showSelectedLabels: true,
          iconSize: 40,
          elevation: 0,
          currentIndex: cubit.currentIndex,
          onTap: cubit.changeIndex,
          backgroundColor: AppColors.primary,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.teal,
          unselectedItemColor: AppColors.grey,
          items:  [
            BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: s.home),
            BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: s.members),
            BottomNavigationBarItem(icon: Icon(Icons.date_range), label:s.schedule),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: s.chat),
            BottomNavigationBarItem(icon: Icon(Icons.person_add_alt), label: s.profile),
          ],
        );
      },
    );
  }
}
