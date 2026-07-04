import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/skin/app_skin_cubit.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/neo_theme.dart';
import '../../../gym/ui/gym_selection_screen.dart';
import '../../../home/manager/member_cubit.dart';
import '../../../home/manager/member_state.dart';
import '../../../ai/ai_tab.dart';
import '../../../ai/ai_tab_neo.dart';
import '../../../eat/widgets/eat_tap.dart';
import '../../../eat/widgets/eat_tab_neo.dart';
import '../../../home/manager/food_cubit.dart';
import '../../../shop/ui/widgets/market_tab.dart';
import '../../../shop/ui/widgets/market_tab_neo.dart';
import '../../../train/widgets/train_tap.dart';
import '../../../train/widgets/train_tab_neo.dart';
import '../../manager/bottom_nav_bar_cubit.dart';
import '../widgets/bottom_nav_bar_view_body.dart';
import '../widgets/home_tab.dart';
import '../widgets/home_tab_neo.dart';
import '../widgets/week_summary_screen.dart';
import '../../../announcements/announcement_overlay.dart';

class BottomNavBarView extends StatefulWidget {
  const BottomNavBarView({super.key});
  static const String routeName = '/nav';

  @override
  State<BottomNavBarView> createState() => BottomNavBarViewState();
}

class BottomNavBarViewState extends State<BottomNavBarView> {
  late final _localProviders = [
    BlocProvider<BottomNavBarCubit>(create: (_) => BottomNavBarCubit()),
    BlocProvider<FoodCubit>(create: (_) => FoodCubit()..loadFoods()),
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
          child: BlocBuilder<AppSkinCubit, AppSkin>(
            builder: (context, skin) {
              final isNeo = skin == AppSkin.neo;
              return Scaffold(
                backgroundColor: isNeo ? NeoColors.bg : AppColors.primary,
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

                        Widget homeBody = isNeo ? const HomeTabNeo() : HomeTab();

                        final bodies = [
                          homeBody,
                          isNeo ? const TrainTabNeo() : trainWidget,
                          isNeo ? const AiTabNeo() : AiTab(),
                          isNeo ? const EatTabNeo() : EatTab(),
                          isNeo ? const MarketTabNeo() : MarketTab(),
                        ];

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: isNeo
                              ? bodies[navCubit.currentIndex]
                              : Padding(
                                  key: const ValueKey('classic'),
                                  padding: const EdgeInsets.all(16),
                                  child: bodies[navCubit.currentIndex],
                                ),
                        );
                      },
                    );
                  },
                ),
                bottomNavigationBar: BottomNavBarViewBody(),
              );
            },
          ),
        ),
      ),
    );
  }
}