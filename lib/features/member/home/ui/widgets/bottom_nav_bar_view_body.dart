import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../../core/theme/app_colors.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/bottom_nav_bar_cubit.dart';

class BottomNavBarViewBody extends StatelessWidget {
  const BottomNavBarViewBody({super.key});

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
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: s.home),
            BottomNavigationBarItem(icon: Icon(Icons.sports_gymnastics), label: s.train),
            BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: s.ai_coach),
            BottomNavigationBarItem(icon: Icon(Icons.restaurant), label:s.eat),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: s.me),
          ],
        );
      },
    );
  }
}
