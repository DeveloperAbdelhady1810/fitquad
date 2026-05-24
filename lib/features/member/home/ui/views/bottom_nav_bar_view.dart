import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../ai/ai_tab.dart';
import '../../../eat/widgets/eat_tap.dart';
import '../../../shop/ui/widgets/market_tab.dart';
import '../../../train/widgets/train_tap.dart';
import '../../manager/bottom_nav_bar_cubit.dart';
import '../widgets/bottom_nav_bar_view_body.dart';
import '../widgets/home_tab.dart';
import '../widgets/week_summary_screen.dart';

class BottomNavBarView extends StatefulWidget {
  const BottomNavBarView({super.key});
  static const String routeName = '/nav';

  @override
  State<BottomNavBarView> createState() => BottomNavBarViewState();
}

class BottomNavBarViewState extends State<BottomNavBarView> {
  List<Map<String, dynamic>>? weekPlan;

  @override
  void initState() {
    super.initState();


    weekPlan = [
      {'type': 'Chest', 'selectedExercises': ['Bench Press', 'Incline Press']},
      {'type': 'Back', 'selectedExercises': ['Pull Up', 'Deadlift']},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trainWidget = (weekPlan != null &&
        weekPlan!.any((day) => (day['selectedExercises'] as List).isNotEmpty))
        ? WeekSummaryScreen(
      weekPlan: weekPlan!,


    )
        : TrainTab();

    List<Widget> homeBodies = [
      HomeTab(),
      trainWidget,
      AiTab(),
      EatTab(),
      MarketTab(),
    ];

    return BlocProvider(
      create: (_) => BottomNavBarCubit(),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
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
            bottomNavigationBar: BottomNavBarViewBody(),
          ),
        ),
      ),
    );
  }
}