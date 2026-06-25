import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../gym/ui/gym_selection_screen.dart';
import '../../../home/manager/member_cubit.dart';
import '../../../home/manager/member_state.dart';
import '../../../ai/ai_tab.dart';
import '../../../eat/widgets/eat_tap.dart';
import '../../../home/manager/food_cubit.dart';
import '../../../shop/ui/widgets/market_tab.dart';
import '../../../train/widgets/train_tap.dart';
import '../../manager/bottom_nav_bar_cubit.dart';
import '../widgets/bottom_nav_bar_view_body.dart';
import '../widgets/home_tab.dart';
import '../widgets/week_summary_screen.dart';
import '../../../announcements/announcement_overlay.dart';

class BottomNavBarView extends StatefulWidget {
  const BottomNavBarView({super.key});
  static const String routeName = '/nav';

  @override
  State<BottomNavBarView> createState() => BottomNavBarViewState();
}

class BottomNavBarViewState extends State<BottomNavBarView> {
  late final List<BlocProviderSingleChildWidget> _localProviders = [
    BlocProvider(create: (_) => BottomNavBarCubit()),
    BlocProvider(create: (_) => FoodCubit()..loadFoods()),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<MemberCubit>().loadAll();
      if (!mounted) return;
      final state = context.read<MemberCubit>().state;
      if (state is MemberLoaded && state.member.needsGymSelection) {
        context.push(GymSelectionScreen.routeName);
      }
    });
  }

  /// Converts the API workout plan (exercises as maps) into the format
  /// WeekSummaryScreen expects (selectedExercises as strings).
  List<Map<String, dynamic>>? _buildWeekPlan(MemberCubit cubit) {
    final plan = cubit.workoutPlan;
    if (plan == null) return null;
    final rawDays = plan['days'] as List?;
    if (rawDays == null || rawDays.isEmpty) return null;
    final days = rawDays.cast<Map<String, dynamic>>();
    final converted = days.map<Map<String, dynamic>>((day) {
      final rawExercises = (day['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final names = rawExercises
          .map((e) =>
              e['name'] as String? ??
              (e['exercise'] as Map?)?['name'] as String? ??
              '')
          .where((n) => n.isNotEmpty)
          .toList();
      // Also support manually-built plans that store exercise names directly
      final fallbackNames = (day['selectedExercises'] as List?)?.cast<String>() ?? [];
      return {
        'type': day['day_name'] as String? ?? day['type'] as String? ?? '',
        'selectedExercises': names.isNotEmpty ? names : fallbackNames,
      };
    }).toList();
    final hasAny = converted.any((d) => (d['selectedExercises'] as List).isNotEmpty);
    return hasAny ? converted : null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: _localProviders,
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return AnnouncementOverlay(
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppColors.primary,
            extendBody: false,
            body: BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
              builder: (context, navState) {
                final navCubit = context.read<BottomNavBarCubit>();
                return BlocBuilder<MemberCubit, MemberState>(
                  builder: (context, memberState) {
                    final memberCubit = context.read<MemberCubit>();
                    final weekPlan = _buildWeekPlan(memberCubit);
                    final trainWidget = weekPlan != null
                        ? WeekSummaryScreen(weekPlan: weekPlan)
                        : const TrainTab();
                    final bodies = [
                      HomeTab(),
                      trainWidget,
                      AiTab(),
                      EatTab(),
                      MarketTab(),
                    ];
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: bodies[navCubit.currentIndex],
                    );
                  },
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