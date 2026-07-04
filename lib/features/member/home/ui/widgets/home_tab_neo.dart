import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/core/widgets/neo_glass_card.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/home/ui/views/workout_active_screen_neo.dart';
import 'package:gym_app/features/member/home/ui/widgets/my_coaches_screen.dart';
import 'package:gym_app/features/member/notifications/notifications_screen_neo.dart';
import 'package:gym_app/features/member/partner_gyms/ui/partner_gyms_screen_neo.dart';
import 'package:gym_app/features/member/profile/ui/widgets/profile_tab.dart';
import 'package:gym_app/features/member/qr/qr_screen_neo.dart';
import 'package:intl/intl.dart';

class HomeTabNeo extends StatefulWidget {
  const HomeTabNeo({super.key});

  @override
  State<HomeTabNeo> createState() => _HomeTabNeoState();
}

class _HomeTabNeoState extends State<HomeTabNeo>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>>? _gymMemberships;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(_pulseCtrl);
    _loadMemberships();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberCubit>().restoreWorkout();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMemberships() async {
    try {
      final res = await ApiClient.get('/member/gym-memberships');
      final raw = res['data'];
      final list = raw is List ? raw : (raw is Map ? (raw['data'] as List? ?? []) : <dynamic>[]);
      if (mounted) {
        setState(() {
          _gymMemberships = list.cast<Map<String, dynamic>>()
              .where((m) => m['status'] == 'active')
              .toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        final cubit = context.read<MemberCubit>();
        final name = state is MemberLoaded ? (state.member.name ?? 'ATHLETE') : 'ATHLETE';
        final weight = state is MemberLoaded ? (state.member.weight ?? 0.0) : 0.0;
        final water = state is MemberLoaded ? (state.member.waterL ?? 0.0) : 0.0;
        final sleep = state is MemberLoaded ? (state.member.sleepHrs ?? 0.0) : 0.0;
        final streak = state is MemberLoaded ? state.member.streakDays : 0;
        final xp = state is MemberLoaded ? state.member.xpPoints : 0;

        return Scaffold(
          backgroundColor: NeoColors.bg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context, name),
                _buildGreeting(name, streak, xp ?? 0),
                SizedBox(height: 16.h),
                _buildWorkoutCard(context, cubit, state),
                SizedBox(height: 16.h),
                _buildBentoGrid(context, weight, water, sleep, state),
                SizedBox(height: 16.h),
                _buildWeeklyChart(cubit),
                SizedBox(height: 16.h),
                _buildGymSection(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0x66131315),
        border: Border(
          bottom: BorderSide(color: NeoColors.cyan.withValues(alpha: 0.15)),
        ),
        boxShadow: [neoCyanGlow(alpha: 0.08, blur: 15)],
      ),
      child: Row(
        children: [
          Text(
            'FITQUAD',
            style: NeoTextStyles.headlineSm.copyWith(
              color: NeoColors.cyan,
              shadows: [Shadow(color: NeoColors.cyan.withValues(alpha: 0.6), blurRadius: 8)],
            ),
          ),
          const Spacer(),
          _neoIconBtn(Icons.qr_code_2, () => showQrSheetNeo(context)),
          SizedBox(width: 8.w),
          _neoIconBtn(Icons.chat_bubble_outline, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyCoachesScreen()))),
          SizedBox(width: 8.w),
          _neoIconBtn(Icons.person_outline, () => context.push(ProfileScreen.routeName)),
          SizedBox(width: 8.w),
          _neoIconBtn(Icons.notifications_none, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreenNeo()))),
        ],
      ),
    );
  }

  Widget _neoIconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: const Color(0x22201F21),
          border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.20)),
        ),
        child: Icon(icon, color: NeoColors.onSurfaceVariant, size: 18.r),
      ),
    );
  }

  Widget _buildGreeting(String name, int streak, int xp) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase(),
            style: NeoTextStyles.labelCaps,
          ),
          SizedBox(height: 4.h),
          Text(
            'HEY, ${name.toUpperCase()}!',
            style: NeoTextStyles.headlineLg.copyWith(
              color: NeoColors.onSurface,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _neoBadge('LVL ${(xp / 100).floor() + 1}', NeoColors.lime),
              SizedBox(width: 8.w),
              _neoBadge('🔥 $streak DAY STREAK', NeoColors.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _neoBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.50)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 8)],
      ),
      child: Text(
        label,
        style: NeoTextStyles.labelCaps.copyWith(color: color),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, MemberCubit cubit, MemberState state) {
    final plan = cubit.workoutPlan;
    final todayOrder = DateTime.now().weekday; // 1=Mon … 7=Sun
    Map<String, dynamic>? todayDay;
    if (plan != null) {
      final days = (plan['days'] as List?)?.cast<Map<String, dynamic>>();
      if (days != null && days.isNotEmpty) {
        todayDay = days.cast<Map<String, dynamic>?>().firstWhere(
          (d) => (d!['order'] as num?)?.toInt() == todayOrder,
          orElse: () => null,
        );
        todayDay ??= days[(todayOrder - 1) % days.length];
      }
    }

    final rawExercises = (todayDay?['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final exercises = rawExercises.isNotEmpty
        ? rawExercises
        : ((todayDay?['selectedExercises'] as List?)?.cast<String>() ?? [])
            .map((n) => <String, dynamic>{'name': n, 'sets': 3, 'reps': 10})
            .toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: NeoGlassCard(
        padding: EdgeInsets.all(16.r),
        borderColor: NeoColors.cyan.withValues(alpha: 0.40),
        boxShadow: [neoCyanGlow(alpha: 0.12, blur: 16)],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('TODAY\'S WORKOUT', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
                const Spacer(),
                FadeTransition(
                  opacity: _pulseAnim,
                  child: Text(
                    cubit.isRunning ? cubit.totalTime : '00:00',
                    style: NeoTextStyles.dataSm.copyWith(color: NeoColors.cyan),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              (plan?['title'] as String? ?? 'NO PLAN YET').toUpperCase(),
              style: NeoTextStyles.headlineMd.copyWith(color: NeoColors.cyan),
            ),
            SizedBox(height: 4.h),
            Text(
              '${exercises.length} EXERCISES',
              style: NeoTextStyles.bodySm,
            ),
            SizedBox(height: 14.h),
            if (exercises.isNotEmpty)
              SizedBox(
                height: 2.h,
                child: LinearProgressIndicator(
                  value: cubit.isRunning
                      ? (cubit.currentExercise + 1) / exercises.length
                      : 0,
                  backgroundColor: NeoColors.surfaceTop,
                  valueColor: AlwaysStoppedAnimation(NeoColors.lime),
                ),
              ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (exercises.isEmpty) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutActiveScreenNeo(
                            exercises: exercises,
                            planTitle: plan?['title'] as String? ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: exercises.isEmpty ? NeoColors.surfaceHigh : NeoColors.cyan,
                        boxShadow: exercises.isEmpty ? [] : [neoCyanGlow(alpha: 0.35, blur: 12)],
                      ),
                      child: Center(
                        child: Text(
                          'START WORKOUT',
                          style: NeoTextStyles.headlineSm.copyWith(
                            color: exercises.isEmpty ? NeoColors.outline : NeoColors.bg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoGrid(BuildContext context, double weight, double water, double sleep, MemberState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _metricTile('WEIGHT', '${weight.toStringAsFixed(1)} KG', NeoColors.cyan, Icons.monitor_weight_outlined, 1.0)),
              SizedBox(width: 8.w),
              Expanded(child: _metricTile('WATER', '${water.toStringAsFixed(1)} L', const Color(0xFF00DCE6), Icons.water_drop_outlined, (water / 3.0).clamp(0.0, 1.0))),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _metricTile('SLEEP', '${sleep.toStringAsFixed(1)} H', NeoColors.lime, Icons.bedtime_outlined, (sleep / 8.0).clamp(0.0, 1.0)),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: _nutritionTile(context, state),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color, IconData icon, double progress) {
    return NeoGlassCard(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14.r),
              SizedBox(width: 6.w),
              Text(label, style: NeoTextStyles.labelCaps),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: color,
              shadows: [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
            ),
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progress,
            minHeight: 1.h,
            backgroundColor: NeoColors.surfaceTop,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ],
      ),
    );
  }

  Widget _nutritionTile(BuildContext context, MemberState state) {
    final plan = context.read<MemberCubit>().nutritionPlan;
    final cals = plan != null ? (plan['total_calories'] as num?)?.toInt() ?? 0 : 0;
    return NeoGlassCard(
      padding: EdgeInsets.all(12.r),
      borderColor: NeoColors.magenta.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: NeoColors.magenta, size: 14.r),
              SizedBox(width: 6.w),
              Text('NUTRITION', style: NeoTextStyles.labelCaps),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            cals > 0 ? '$cals KCAL' : 'VIEW PLAN',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: NeoColors.magenta,
            ),
          ),
          SizedBox(height: 4.h),
          Text('DAILY GOAL', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.outline)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(MemberCubit cubit) {
    final checkIns = cubit.weekCheckIns;
    final maxVal = checkIns.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final todayIdx = DateTime.now().weekday - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: NeoGlassCard(
        padding: EdgeInsets.all(14.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WEEKLY ACTIVITY', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
            SizedBox(height: 14.h),
            SizedBox(
              height: 70.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final val = checkIns[i];
                  final pct = val / maxVal;
                  final isToday = i == todayIdx;
                  final color = val > 0
                      ? (isToday ? NeoColors.cyan : NeoColors.lime)
                      : NeoColors.surfaceTop;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 400 + i * 50),
                            height: 54.h * pct.clamp(0.05, 1.0),
                            decoration: BoxDecoration(
                              color: color,
                              boxShadow: val > 0
                                  ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)]
                                  : null,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            days[i],
                            style: NeoTextStyles.labelCaps.copyWith(
                              color: isToday ? NeoColors.cyan : NeoColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymSection() {
    final memberships = _gymMemberships;
    if (memberships == null || memberships.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('YOUR GYMS', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.cyan)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnerGymsScreenNeo())),
                child: Text('BROWSE ALL ›', style: NeoTextStyles.labelCaps.copyWith(color: NeoColors.lime)),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...memberships.take(2).map((m) {
            final gym = m['gym'] as Map<String, dynamic>? ?? {};
            final name = gym['name'] as String? ?? 'Gym';
            final level = gym['crowd_level'] as String? ?? 'quiet';
            final today = (gym['attendance_today'] as num?)?.toInt() ?? 0;
            final capacity = (gym['capacity'] as num?)?.toInt() ?? 100;
            final pct = capacity > 0 ? (today / capacity).clamp(0.0, 1.0) : 0.0;
            final (badgeColor, badgeLabel) = switch (level) {
              'crowded' => (NeoColors.magenta, 'BUSY'),
              'moderate' => (NeoColors.cyan, 'MODERATE'),
              _ => (NeoColors.lime, 'QUIET'),
            };
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: NeoGlassCard(
                padding: EdgeInsets.all(12.r),
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      color: NeoColors.cyan.withValues(alpha: 0.10),
                      child: Icon(Icons.location_on, color: NeoColors.cyan, size: 18.r),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.toUpperCase(), style: NeoTextStyles.headlineSm.copyWith(fontSize: 13.sp, color: NeoColors.cyan)),
                          SizedBox(height: 4.h),
                          LinearProgressIndicator(
                            value: pct,
                            minHeight: 2.h,
                            backgroundColor: NeoColors.surfaceTop,
                            valueColor: AlwaysStoppedAnimation(badgeColor),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(badgeLabel, style: NeoTextStyles.labelCaps.copyWith(color: badgeColor, fontSize: 9.sp)),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
