import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/enums/choose_coach.dart';
import 'package:gym_app/features/member/gym/models/gym_model.dart';
import 'package:gym_app/features/member/home/ui/widgets/choose_coach_screen.dart';
import 'package:gym_app/features/member/home/ui/widgets/plan_dilog.dart';
import 'package:gym_app/features/member/community/community_feed_screen.dart';
import 'package:gym_app/features/member/partner_gyms/ui/partner_gyms_screen.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/features/member/gamification/streak_card.dart';
import 'package:gym_app/features/member/notifications/notifications_screen.dart';
import 'package:gym_app/features/member/qr/qr_screen.dart';
import 'package:gym_app/features/member/home/manager/bottom_nav_bar_cubit.dart';
import 'package:gym_app/features/member/train/widgets/design_manually_screen.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/home/ui/widgets/water_dialog.dart';
import 'package:gym_app/features/member/home/ui/views/workout_active_screen.dart';
import '../../../../../core/cubit/health/health_cubit.dart';
import '../../../../../core/services/health_pdf_service.dart';
import '../../../../../core/services/health_service.dart';
import '../../../../../features/member/data/repositories/member_repository.dart';
import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import 'package:gym_app/features/member/data/models/member_model.dart';
import 'package:gym_app/features/member/home/ui/widgets/my_coaches_screen.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';
import 'column_chart.dart';
import 'food_dialog.dart';
import 'nutrition_progress_container.dart';
import 'sleep_dialog.dart';
import 'weight_dialog.dart';
import '../../../profile/ui/widgets/profile_tab.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  PageController? pageController;
  CrowdingInfo? _crowding;

  @override
  void initState() {
    super.initState();
    _initWorkout();
  }

  Future<void> _initWorkout() async {
    final cubit = context.read<MemberCubit>();
    await cubit.restoreWorkout();

    pageController = PageController(
      initialPage:
      cubit.currentExercise.clamp(0, cubit.totalExercises - 1),
    );

    if (mounted) setState(() {});
    _loadCrowding();
  }

  Future<void> _loadCrowding() async {
    try {
      final state = context.read<MemberCubit>().state;
      if (state is! MemberLoaded) return;
      final branchId = state.member.branchId;
      if (branchId == null) return;
      final raw = await MemberRepository.getBranchCrowding(branchId);
      if (mounted) setState(() => _crowding = CrowdingInfo.fromJson(raw));
    } catch (_) {}
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        double weight = 0;
        double sleepHrs = 0;
        double waterL = 0;

        if (state is MemberLoaded) {
          weight = state.member.weight ?? 0;
          sleepHrs = state.member.sleepHrs ?? 0;
          waterL = state.member.waterL ?? 0;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                automaticallyImplyLeading: false,
                titleSpacing: -15,
                toolbarHeight: 100,
                backgroundColor: AppColors.primary,
                title: ListTile(
                  title: Text(
                    DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: AppTextStyles.font14GreyRegular,
                  ),
                  subtitle: Text(
                    'Hello, ${state is MemberLoaded ? (state.member.name ?? 'there') : '...'}',
                    style: AppTextStyles.font16WhiteBold,
                  ),
                ),
                actions: [
                  _iconButton(Icons.qr_code_2, () => showQrSheet(context)),
                  hGap(10),
                  _iconButton(
                    Icons.chat_bubble_outline,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyCoachesScreen(),
                      ),
                    ),
                  ),
                  hGap(10),
                  _iconButton(
                    Icons.person_outline,
                        () => context.push(ProfileScreen.routeName),
                  ),
                  hGap(10),
                  _iconButton(Icons.notifications_none, () => context.push(NotificationsScreen.routeName)),
                ],
              ),
              vGap(10),
              const StreakCard(),
              vGap(12),
              // Quick-access banners at the top so they're always visible
              Row(
                children: [
                  Expanded(child: _PartnerGymsBanner()),
                  hGap(10),
                  Expanded(child: _CommunityBanner()),
                ],
              ),
              vGap(12),
              if (state is MemberLoaded &&
                  state.member.status == MemberStatus.expiring) ...[
                _ExpiryBanner(),
                vGap(10),
              ],
              if (state is MemberLoaded &&
                  state.member.streakDays >= 10 &&
                  state.member.type == null) ...[
                _CoachUpsellBanner(),
                vGap(10),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.todays_workout,
                      style: AppTextStyles.font16WhiteBold),
                  TextButton(
                    onPressed: () => showWeekDialog(context),
                    child: Text(
                      s.view_plan,
                      style: AppTextStyles.font16WhiteBold.copyWith(
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
              vGap(10),
              _buildWorkoutCard(context, state),
              if (_crowding != null) ...[
                vGap(10),
                _CrowdingBanner(info: _crowding!),
              ],
              vGap(10),
              _GymSubscriptionsWidget(),
              vGap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(s.nutrition,
                      style: AppTextStyles.font16WhiteBold),
                  CustomButton(
                    text: s.log_meal,
                    onPressed: () => showFoodDialog(context),
                    iconData: Icons.add,
                    iconBeforeText: true,
                    width: 150,
                  ),
                ],
              ),
              vGap(10),
              _buildNutritionRow(context, s),
              vGap(15),
              Text(s.activity,
                  style: AppTextStyles.font16WhiteBold),
              vGap(10),
              Container(
                height: 200.h,
                decoration: AppDecorations.containerDecoration,
                child: WeeklyColumnChart(
                  values: context.read<MemberCubit>().weekCheckIns,
                  maxY: context.read<MemberCubit>().weekCheckIns.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity),
                  barColor: AppColors.teal,
                ),
              ),
              vGap(15),
              Row(
                children: [
                  _buildListTile(
                    onTap: () => showWeightDialog(context),
                    value: weight,
                    subtitle: s.weight_kg,
                    color: AppColors.teal,
                  ),
                  hGap(5),
                  _buildListTile(
                    onTap: () => showSleepDialog(context),
                    value: sleepHrs,
                    subtitle: s.sleep_hrs,
                    color: AppColors.blue,
                  ),
                  hGap(5),
                  _buildListTile(
                    onTap: () => showWaterDialog(context),
                    value: waterL,
                    subtitle: s.water_l,
                    color: AppColors.purple,
                  ),
                ],
              ),
              vGap(15),
              BlocBuilder<HealthCubit, HealthState>(
                builder: (context, healthState) {
                  if (healthState is HealthLoaded) {
                    return _WatchStatsRow(snapshot: healthState.snapshot);
                  }
                  if (healthState is HealthPermissionDenied) {
                    return _WatchPermissionBanner();
                  }
                  return const SizedBox.shrink();
                },
              ),
              vGap(15),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutCard(BuildContext context, MemberState state) {
    final cubit = context.read<MemberCubit>();
    final plan = cubit.workoutPlan;

    if (plan == null) {
      return _NoPlanCard();
    }

    // Find today's workout day by order (1=Mon … 7=Sun)
    final todayOrder = DateTime.now().weekday; // 1=Mon, 7=Sun
    Map<String, dynamic>? todayDay;
    try {
      final days = plan['days'] as List?;
      if (days != null && days.isNotEmpty) {
        final castDays = days.cast<Map<String, dynamic>>();
        // 1. Try exact match by order field
        todayDay = castDays.cast<Map<String, dynamic>?>().firstWhere(
          (d) => (d!['order'] as num?)?.toInt() == todayOrder,
          orElse: () => null,
        );
        // 2. Cycle through the plan with modulo so a 2-day plan loops every week
        todayDay ??= castDays[(todayOrder - 1) % castDays.length];
      }
    } catch (_) {}

    if (todayDay == null) return _NoPlanCard();

    final title = todayDay['day_name'] as String? ??
        todayDay['type'] as String? ??
        'Day ${todayDay['order']}';
    // Primary format: exercises as maps (API / coach-applied plan)
    final rawExercises = (todayDay['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    // Fallback: manually-built plan stores exercise names as strings
    final List<Map<String, dynamic>> exercises = rawExercises.isNotEmpty
        ? rawExercises
        : ((todayDay['selectedExercises'] as List?)?.cast<String>() ?? [])
            .map((name) => <String, dynamic>{'name': name, 'sets': 3, 'reps': 10})
            .toList();
    final status = cubit.todayWorkoutStatus;

    return _RealWorkoutCard(
      title: title,
      planTitle: plan['title'] as String? ?? 'Workout Plan',
      exercises: exercises,
      status: status,
      onStart: () {
        final title = plan['title'] as String? ?? 'Workout Plan';
        context.push(
          WorkoutActiveScreen.routeName,
          extra: {
            'exercises': exercises,
            'plan_title': title,
          },
        );
      },
      onMarkDone: () => cubit.markWorkoutDone('done'),
      onMarkSemi: () => cubit.markWorkoutDone('semi'),
    );
  }

  Widget _buildNutritionRow(BuildContext context, dynamic s) {
    final cubit = context.read<MemberCubit>();
    final plan = cubit.nutritionPlan;

    double caloriesTarget = 2400;
    double proteinTarget = 180;
    // If the nutrition plan has targets, use them
    if (plan != null) {
      try {
        caloriesTarget =
            (plan['calorie_target'] as num?)?.toDouble() ?? caloriesTarget;
        proteinTarget =
            (plan['protein_target'] as num?)?.toDouble() ?? proteinTarget;
      } catch (_) {}
    }

    return Row(
      children: [
        Expanded(
          child: NutritionProgressContainer(
            title: s.calories,
            value: 0,
            target: caloriesTarget,
            icon: Icon(
              Icons.local_fire_department_outlined,
              color: AppColors.red,
            ),
          ),
        ),
        Expanded(
          child: NutritionProgressContainer(
            title: s.protein,
            value: 0.0,
            target: proteinTarget,
            icon: Icon(
              Icons.circle_outlined,
              color: AppColors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required void Function()? onTap,
    required String subtitle,
    required double value,
    required Color color,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: AppDecorations.containerDecoration,
          padding: const EdgeInsets.all(8),
          height: 110,
          child: ListTile(
            title: Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.font16WhiteBold.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              subtitle.toUpperCase(),
              style: AppTextStyles.font14GreyRegular,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, void Function()? onPressed) {
    return Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(30),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.grey),
      ),
    );
  }
}

// ── Smartwatch stats row ─────────────────────────────────────────────────────

class _WatchStatsRow extends StatelessWidget {
  final HealthSnapshot snapshot;
  const _WatchStatsRow({required this.snapshot});

  Future<void> _exportPdf(BuildContext context, String memberName) async {
    try {
      final bytes = await HealthPdfService.generateReport(
        snapshot: snapshot,
        memberName: memberName,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'fitquad-health-${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not export PDF: $e')),
        );
      }
    }
  }

  Future<void> _sendToCoach(BuildContext context, String memberName) async {
    // Load the member's coaches first
    List<Map<String, dynamic>> coaches;
    try {
      final raw = await MemberRepository.getMyCoaches();
      coaches = raw.cast<Map<String, dynamic>>();
    } catch (_) {
      coaches = [];
    }

    if (!context.mounted) return;

    if (coaches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "You don't have a coach yet. Go to Personal Training to hire one."),
        ),
      );
      return;
    }

    // If one coach, send directly; otherwise let the member pick
    Map<String, dynamic>? chosen;
    if (coaches.length == 1) {
      chosen = coaches.first;
    } else {
      chosen = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        builder: (_) => _CoachPickerSheet(coaches: coaches),
      );
    }

    if (chosen == null || !context.mounted) return;

    final coachId = chosen['coach_id'] as int?;
    final coachName = chosen['name'] as String? ?? 'your coach';
    final body = _buildSummaryText(memberName);
    try {
      await MemberRepository.sendMessageToCoach(body, coachId: coachId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health summary sent to $coachName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not send the summary. Please try again.')),
        );
      }
    }
  }

  String _buildSummaryText(String memberName) {
    final date = DateFormat('MMMM d, yyyy').format(DateTime.now());
    return '''📊 Health Summary — $date
Member: $memberName

👟 Steps: ${snapshot.steps}
❤️ Heart Rate: ${snapshot.heartRateBpm > 0 ? '${snapshot.heartRateBpm} bpm' : 'No data'}
🌙 Sleep: ${snapshot.sleepHrs > 0 ? '${snapshot.sleepHrs.toStringAsFixed(1)} hours' : 'No data'}
🔥 Active Calories: ${snapshot.caloriesBurned} kcal

Sent via FitQuad app.''';
  }

  @override
  Widget build(BuildContext context) {
    final memberName =
        (context.read<MemberCubit>().state is MemberLoaded)
            ? ((context.read<MemberCubit>().state as MemberLoaded).member.name ?? 'Member')
            : 'Member';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.watch, color: AppColors.grey, size: 16.sp),
                hGap(6),
                Text('Smart Watch', style: AppTextStyles.font14GreyRegular),
              ],
            ),
            // Action buttons
            Row(
              children: [
                _ActionChip(
                  icon: Icons.picture_as_pdf,
                  label: 'Export PDF',
                  color: AppColors.red,
                  onTap: () => _exportPdf(context, memberName),
                ),
                hGap(8),
                _ActionChip(
                  icon: Icons.send,
                  label: 'Send to Coach',
                  color: AppColors.teal,
                  onTap: () => _sendToCoach(context, memberName),
                ),
              ],
            ),
          ],
        ),
        vGap(10),
        // Stat cards
        Row(
          children: [
            _WatchStat(
              icon: Icons.directions_walk,
              value: snapshot.steps.toString(),
              label: 'STEPS',
              color: AppColors.teal,
            ),
            hGap(5),
            _WatchStat(
              icon: Icons.favorite,
              value: snapshot.heartRateBpm > 0
                  ? '${snapshot.heartRateBpm}'
                  : '—',
              unit: 'bpm',
              label: 'HEART RATE',
              color: AppColors.red,
            ),
            hGap(5),
            _WatchStat(
              icon: Icons.local_fire_department,
              value: '${snapshot.caloriesBurned}',
              unit: 'kcal',
              label: 'ACTIVE CAL',
              color: AppColors.emerald,
            ),
            hGap(5),
            _WatchStat(
              icon: Icons.bedtime,
              value: snapshot.sleepHrs > 0
                  ? snapshot.sleepHrs.toStringAsFixed(1)
                  : '—',
              unit: snapshot.sleepHrs > 0 ? 'hrs' : '',
              label: 'SLEEP',
              color: AppColors.blue,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 13.sp),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppTextStyles.font14GreyRegular.copyWith(
                color: color,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;
  const _WatchStat({
    required this.icon,
    required this.value,
    this.unit = '',
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: AppDecorations.containerDecoration,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18.sp),
            vGap(4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                unit.isEmpty ? value : '$value $unit',
                style: AppTextStyles.font14GreyRegular.copyWith(
                  color: color,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            vGap(2),
            Text(
              label,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 8.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── No Plan Card ─────────────────────────────────────────────────────────────

class _NoPlanCard extends StatelessWidget {
  const _NoPlanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: AppDecorations.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: AppColors.grey, size: 20.r),
              hGap(8),
              Text('No Workout Plan Yet', style: AppTextStyles.font16WhiteBold),
            ],
          ),
          vGap(8),
          Text(
            'Create a plan to start tracking your workouts.',
            style: AppTextStyles.font14GreyRegular,
          ),
          vGap(16),
          _PlanOptionButton(
            icon: Icons.edit_note_outlined,
            label: 'Design Manually',
            color: AppColors.blue,
            onTap: () => context.push(DesignPlanManuallyScreen.routeName),
          ),
          vGap(8),
          _PlanOptionButton(
            icon: Icons.smart_toy_outlined,
            label: 'Ask AI Coach',
            color: AppColors.teal,
            onTap: () => context.read<BottomNavBarCubit>().changeIndex(2),
          ),
          vGap(8),
          _PlanOptionButton(
            icon: Icons.sports_gymnastics,
            label: 'Hire a Coach',
            color: AppColors.purple,
            onTap: () => context.push(ChooseCoachScreen.routeName, extra: ChooseCoachSource.train),
          ),
        ],
      ),
    );
  }
}

class _PlanOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PlanOptionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18.r),
            hGap(10),
            Text(label, style: AppTextStyles.font14WhiteRegular.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Real Workout Card ─────────────────────────────────────────────────────────

class _RealWorkoutCard extends StatelessWidget {
  final String title;
  final String planTitle;
  final List<Map<String, dynamic>> exercises;
  final String? status;
  final VoidCallback onStart;
  final VoidCallback onMarkDone;
  final VoidCallback onMarkSemi;

  const _RealWorkoutCard({
    required this.title,
    required this.planTitle,
    required this.exercises,
    required this.status,
    required this.onStart,
    required this.onMarkDone,
    required this.onMarkSemi,
  });

  @override
  Widget build(BuildContext context) {
    final s     = S.of(context);
    final isDone = status == 'done';
    final isSemi = status == 'semi';
    final statusColor = isDone ? AppColors.emerald : isSemi ? const Color(0xFFFFD700) : null;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: AppDecorations.containerDecoration.copyWith(
        border: Border(
          right: BorderSide(
            color: statusColor ?? AppColors.emerald,
            width: 7,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.font16WhiteBold),
                    vGap(2),
                    Text(planTitle,
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(color: AppColors.emerald, fontSize: 11.sp)),
                  ],
                ),
              ),
              if (isDone)
                _StatusChip(label: 'Done', color: AppColors.emerald, icon: Icons.check_circle)
              else if (isSemi)
                _StatusChip(label: 'Partial', color: const Color(0xFFFFD700), icon: Icons.remove_circle_outline),
            ],
          ),
          vGap(12),
          if (exercises.isNotEmpty) ...[
            ...exercises.take(4).map((ex) {
              final name = ex['name'] as String? ?? 'Exercise';
              final pivot = ex['pivot'] as Map<String, dynamic>? ?? {};
              final sets = pivot['sets']?.toString() ?? '3';
              final reps = pivot['reps']?.toString() ?? '12';
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 3.h),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 6.r, color: AppColors.teal),
                    hGap(8),
                    Expanded(child: Text(name, style: AppTextStyles.font14GreyRegular)),
                    Text('$sets×$reps',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(color: AppColors.teal, fontSize: 12.sp)),
                  ],
                ),
              );
            }),
            if (exercises.length > 4)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text('+${exercises.length - 4} more exercises',
                    style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 11.sp)),
              ),
          ] else
            Text(s.rest_day_no_exercises,
                style: AppTextStyles.font14GreyRegular),
          vGap(14),
          const Divider(),
          vGap(8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: Icon(Icons.play_arrow, size: 16.r),
                  label: Text(s.start_workout, style: AppTextStyles.font14WhiteRegular),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              hGap(6),
              Expanded(
                child: OutlinedButton(
                  onPressed: isDone ? null : onMarkDone,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDone ? Colors.grey : AppColors.emerald),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  child: Text(s.workout_done,
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: isDone ? Colors.grey : AppColors.emerald, fontSize: 12.sp)),
                ),
              ),
              hGap(6),
              Expanded(
                child: OutlinedButton(
                  onPressed: isSemi ? null : onMarkSemi,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isSemi ? Colors.grey : const Color(0xFFFFD700)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                  child: Text(s.workout_partial,
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(color: isSemi ? Colors.grey : const Color(0xFFFFD700), fontSize: 12.sp)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12.r),
          SizedBox(width: 4.w),
          Text(label, style: AppTextStyles.font14GreyRegular.copyWith(color: color, fontSize: 11.sp)),
        ],
      ),
    );
  }
}

class _CrowdingBanner extends StatelessWidget {
  final CrowdingInfo info;
  const _CrowdingBanner({required this.info});

  @override
  Widget build(BuildContext context) {
    final isCrowded = info.level == 'crowded';
    final isModerate = info.level == 'moderate';
    final color = isCrowded ? AppColors.red : isModerate ? const Color(0xFFFFD700) : AppColors.emerald;
    final icon = isCrowded ? Icons.warning_amber_rounded : Icons.check_circle_outline;
    final msg = isCrowded
        ? '${info.branchName} is busy — ~${info.checkIns} people training now'
        : isModerate
            ? '${info.branchName} is moderately busy (~${info.checkIns} people)'
            : 'Good time to train — only ~${info.checkIns} people at ${info.branchName}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: AppDecorations.containerDecoration.copyWith(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        color: color.withValues(alpha: 0.08),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18.r),
          hGap(10),
          Expanded(
            child: Text(msg,
                style: AppTextStyles.font14GreyRegular.copyWith(color: color, fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }
}

// ── Gym Subscriptions Widget (shows active gym memberships with crowd counter) ──

class _GymSubscriptionsWidget extends StatefulWidget {
  @override
  State<_GymSubscriptionsWidget> createState() => _GymSubscriptionsWidgetState();
}

class _GymSubscriptionsWidgetState extends State<_GymSubscriptionsWidget> {
  List<dynamic> _memberships = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.get('/member/gym-memberships');
      final list = (res['data'] as List?) ?? [];
      final active = list.where((m) {
        final s = (m as Map<String, dynamic>)['status'] as String?;
        return s == 'active' || s == 'frozen';
      }).toList();
      if (mounted) setState(() { _memberships = active; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _memberships.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Gyms', style: AppTextStyles.font16WhiteBold),
        vGap(8),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _memberships.length,
            separatorBuilder: (_, __) => hGap(10),
            itemBuilder: (_, i) {
              final m = _memberships[i] as Map<String, dynamic>;
              final gym = m['gym'] as Map<String, dynamic>? ?? {};
              final today = (gym['attendance_today'] as num?)?.toInt() ?? 0;
              final capacity = (gym['capacity'] as num?)?.toInt() ?? 100;
              final crowdLevel = gym['crowd_level'] as String? ?? 'quiet';
              final status = m['status'] as String? ?? 'active';
              final isFrozen = status == 'frozen';
              final daysLeft = (m['days_remaining'] as num?)?.toInt() ?? 0;

              final crowdColor = crowdLevel == 'crowded'
                  ? Colors.redAccent
                  : crowdLevel == 'moderate'
                      ? const Color(0xFFFFD700)
                      : AppColors.emerald;

              return Container(
                width: 180.w,
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isFrozen
                        ? const Color(0xFF4D8DBD).withValues(alpha: 0.4)
                        : AppColors.teal.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(
                        isFrozen ? Icons.ac_unit : Icons.fitness_center,
                        color: isFrozen ? const Color(0xFF4D8DBD) : AppColors.teal,
                        size: 14.r,
                      ),
                      hGap(6),
                      Expanded(
                        child: Text(
                          gym['name'] as String? ?? 'Gym',
                          style: AppTextStyles.font14WhiteRegular
                              .copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    vGap(6),
                    // Crowd count
                    Row(children: [
                      Icon(Icons.people_outline, color: crowdColor, size: 13.r),
                      hGap(4),
                      Text('$today here now',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(color: crowdColor, fontSize: 11.sp)),
                    ]),
                    vGap(4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3.r),
                      child: LinearProgressIndicator(
                        value: capacity > 0
                            ? (today / capacity).clamp(0.0, 1.0)
                            : 0,
                        backgroundColor: Colors.white12,
                        color: crowdColor,
                        minHeight: 4.h,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isFrozen
                          ? '❄️ Frozen'
                          : '$daysLeft days left',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(fontSize: 10.sp),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PartnerGymsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(PartnerGymsScreen.routeName),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.teal.withOpacity(0.3), AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.teal.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🏋️', style: TextStyle(fontSize: 22.sp)),
            vGap(6),
            Text('Gyms',
                style: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w700)),
            Text('Browse & join',
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }
}

class _CommunityBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(CommunityFeedScreen.routeName),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1B2A6B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('👥', style: TextStyle(fontSize: 22.sp)),
            vGap(6),
            Text(S.of(context).community_feed,
                style: AppTextStyles.font14WhiteRegular
                    .copyWith(fontWeight: FontWeight.w700)),
            Text(S.of(context).share_wins,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }
}

class _ExpiryBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_outlined, color: Colors.orange, size: 20.r),
          hGap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membership expiring soon',
                  style: AppTextStyles.font14WhiteRegular.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  'Renew now to keep your streak and benefits alive!',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 11.sp),
                ),
              ],
            ),
          ),
          hGap(8),
          GestureDetector(
            onTap: () {/* navigate to renewal */},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text('Renew',
                  style: AppTextStyles.font14GreyRegular.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.sp)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachUpsellBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        ChooseCoachScreen.routeName,
        extra: ChooseCoachSource.train,
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.purple.withValues(alpha: 0.25),
              AppColors.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Text('🏆', style: TextStyle(fontSize: 24.sp)),
            hGap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You're serious about this!",
                    style: AppTextStyles.font14WhiteRegular.copyWith(
                        fontWeight: FontWeight.w600),
                  ),
                  vGap(2),
                  Text(
                    'Want a coach? First session free — tap to explore',
                    style: AppTextStyles.font14GreyRegular.copyWith(
                        fontSize: 11.sp, color: AppColors.purple),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14.r, color: AppColors.purple),
          ],
        ),
      ),
    );
  }
}

class _WatchPermissionBanner extends StatelessWidget {
  const _WatchPermissionBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: EdgeInsets.all(12.r),
      child: Row(
        children: [
          Icon(Icons.watch_off, color: AppColors.grey, size: 20.sp),
          hGap(10),
          Expanded(
            child: Text(
              'Connect a smartwatch in Health settings to see live stats here.',
              style: AppTextStyles.font14GreyRegular,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Coach picker sheet (analytics → which coach?) ─────────────────────────────

class _CoachPickerSheet extends StatelessWidget {
  final List<Map<String, dynamic>> coaches;
  const _CoachPickerSheet({required this.coaches});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.send_outlined, color: AppColors.teal, size: 20.r),
                hGap(10),
                Text('Send to which coach?',
                    style: AppTextStyles.font16WhiteBold),
              ],
            ),
            vGap(14),
            ...coaches.map((c) {
              final name = c['name'] as String? ?? 'Coach';
              final spec = c['specialization'] as String? ?? '';
              final initials = name.trim().split(' ').take(2)
                  .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
                  .join();
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, c),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20.r,
                          backgroundColor: AppColors.teal.withValues(alpha: 0.15),
                          child: Text(initials,
                              style: AppTextStyles.font14WhiteRegular
                                  .copyWith(color: AppColors.teal)),
                        ),
                        hGap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: AppTextStyles.font14WhiteRegular
                                      .copyWith(fontWeight: FontWeight.w600)),
                              if (spec.isNotEmpty)
                                Text(spec,
                                    style: AppTextStyles.font14GreyRegular
                                        .copyWith(fontSize: 11.sp,
                                            color: AppColors.teal)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            color: AppColors.grey, size: 18.r),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}