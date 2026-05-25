import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/member/gym/models/gym_model.dart';
import 'package:gym_app/features/member/home/ui/widgets/plan_dilog.dart';
import 'package:gym_app/features/member/notifications/notifications_screen.dart';
import 'package:gym_app/features/member/qr/qr_screen.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/home/ui/widgets/water_dialog.dart';
import 'package:gym_app/features/member/home/ui/widgets/workout_dialog.dart';
import '../../../../../core/cubit/health/health_cubit.dart';
import '../../../../../core/services/health_pdf_service.dart';
import '../../../../../core/services/health_service.dart';
import '../../../../../features/member/data/repositories/member_repository.dart';
import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';
import 'column_chart.dart';
import 'food_dialog.dart';
import 'nutrition_progress_container.dart';
import 'sleep_dialog.dart';
import 'weight_dialog.dart';
import 'workout_card.dart';
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
                    Icons.person_outline,
                        () => context.push(ProfileScreen.routeName),
                  ),
                  hGap(10),
                  _iconButton(Icons.notifications_none, () => context.push(NotificationsScreen.routeName)),
                ],
              ),
              vGap(10),
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
              vGap(15),
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
                  values: [30, 50, 20, 80, 60, 40, 70],
                  maxY: 100,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutCard(BuildContext context, MemberState state) {
    final cubit = context.read<MemberCubit>();
    final plan = cubit.workoutPlan;

    String title = 'Upper Body Power';
    String subtitle = 'Chest, Shoulders & Triceps';

    if (plan != null) {
      try {
        final now = DateTime.now();
        final dayIndex = now.weekday - 1; // 0=Mon … 6=Sun
        final days = plan['days'] as List?;
        if (days != null && dayIndex < days.length) {
          final today = days[dayIndex] as Map<String, dynamic>;
          title = today['title'] as String? ??
              today['muscle_group'] as String? ??
              today['type'] as String? ??
              title;
          final exList = today['exercises'] as List?;
          if (exList != null && exList.isNotEmpty) {
            subtitle = exList
                .take(3)
                .map((e) => (e['name'] ?? e.toString()).toString())
                .join(', ');
          }
        }
      } catch (_) {}
    }

    return WorkoutCard(
      title: title,
      subtitle: subtitle,
      duration: '45 min',
      calories: '320 kcal',
      exercisesCount: '8 Exercises',
      onStart: () async {
        await cubit.restoreWorkout();
        if (pageController != null && context.mounted) {
          showWorkoutDialog(context, pageController: pageController!);
        }
      },
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
          padding: const EdgeInsets.all(10),
          height: 100,
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
    final body = _buildSummaryText(memberName);
    try {
      await MemberRepository.sendMessageToCoach(body);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health summary sent to your coach!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final errStr = e.toString().toLowerCase();
        final msg = errStr.contains('coach') || errStr.contains('assign')
            ? "You don't have an assigned coach yet. Go to Personal Training to request one."
            : 'Could not send the summary. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
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