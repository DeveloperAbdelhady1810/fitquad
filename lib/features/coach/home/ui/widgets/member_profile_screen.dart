import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/helpers.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/features/coach/chat/widgets/send_plan_sheet.dart';
import 'package:gym_app/core/enums/member_type.dart';
import 'package:gym_app/features/member/data/models/member_model.dart';

import '../../../../../generated/l10n.dart';

class MemberProfileScreen extends StatefulWidget {
  final MemberModel member;

  const MemberProfileScreen({super.key, required this.member});
  static const String routeName = '/member-profile';

  @override
  State<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends State<MemberProfileScreen> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final memberId = widget.member.id ?? '';
      final res = await ApiClient.get('/coach/members/$memberId');
      setState(() {
        _detail = res['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final m = widget.member;
    final initials = Helpers.getInitials(m.name ?? '');

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.white),
        backgroundColor: AppColors.primary,
        title: Text(s.member_profile, style: AppTextStyles.font14WhiteRegular),
        actions: [
          IconButton(
            icon: Icon(Icons.note_add_outlined,
                color: AppColors.emerald, size: 22.r),
            tooltip: 'Send Plan',
            onPressed: () {
              final userId =
                  _detail?['user']?['id'] as int? ??
                  int.tryParse(m.id ?? '0') ?? 0;
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => SendPlanSheet(
                  memberUserId: userId,
                  memberName: m.name ?? 'Member',
                  onSent: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Plan sent to ${m.name}! ✅'),
                      backgroundColor: AppColors.emerald,
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.teal))
          : DefaultTabController(
              length: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────────
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.teal.withValues(alpha: 0.2),
                          radius: 26.r,
                          child: Text(initials,
                              style: AppTextStyles.font14WhiteRegular
                                  .copyWith(color: AppColors.teal,
                                      fontWeight: FontWeight.w700)),
                        ),
                        hGap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name ?? '',
                                  style: AppTextStyles.font16WhiteBold),
                              vGap(3),
                              Wrap(
                                spacing: 6.w,
                                runSpacing: 4.h,
                                children: [
                                  if (m.type != null)
                                    _Chip(m.type!.label(context), AppColors.blue),
                                  if (m.weight != null)
                                    _Chip('${m.weight} kg', AppColors.teal),
                                  if (m.status != null)
                                    _Chip(m.status!.name, _statusColor(m.status!.name)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Tabs ───────────────────────────────────────────
                  CustomTabBar(
                    isScrollable: true,
                    tabs: [
                      Tab(text: s.overview),
                      Tab(text: s.training),
                      Tab(text: s.nutrition),
                      Tab(text: s.inbody),
                      const Tab(text: 'Analytics'),
                      Tab(text: s.messages),
                    ],
                  ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(detail: _detail, member: m),
                        _TrainingTab(detail: _detail),
                        _NutritionTab(detail: _detail),
                        _InBodyTab(detail: _detail),
                        _AnalyticsTab(memberId: m.id ?? ''),
                        _MessagesTab(member: m, detail: _detail),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _statusColor(String s) => switch (s) {
        'active'   => AppColors.emerald,
        'expiring' => Colors.orange,
        _          => AppColors.grey,
      };
}

// ── Overview tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final Map<String, dynamic>? detail;
  final MemberModel member;
  const _OverviewTab({required this.detail, required this.member});

  @override
  Widget build(BuildContext context) {
    final sessions = (detail?['coach_sessions'] as List?)?.cast<Map>() ?? [];
    final checkIns = detail?['check_ins_this_week'] as int? ?? 0;
    final streak   = detail?['streak_days'] as int? ?? 0;
    final xp       = detail?['xp_points'] as int? ?? 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          Row(
            children: [
              _StatCard('Check-ins\nThis Week', '$checkIns',
                  Icons.fitness_center_outlined, AppColors.teal),
              hGap(10),
              _StatCard('Streak', '$streak days',
                  Icons.local_fire_department_outlined, Colors.orange),
              hGap(10),
              _StatCard('XP Points', '$xp',
                  Icons.emoji_events_outlined, AppColors.emerald),
            ],
          ),
          vGap(16),

          // Recent sessions
          Text('Recent Sessions', style: AppTextStyles.font16WhiteBold),
          vGap(8),
          if (sessions.isEmpty)
            _EmptyInfo('No sessions recorded yet')
          else
            ...sessions.take(5).map((s) => _SessionRow(session: s)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.r),
            vGap(4),
            Text(value,
                style: AppTextStyles.font14WhiteRegular.copyWith(
                    color: color, fontWeight: FontWeight.bold)),
            Text(label,
                style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 9.sp),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final Map session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final status    = session['status'] as String? ?? '';
    final startTime = session['start_time'] as String? ?? '';
    final type      = session['type'] as String? ?? '';
    final dt        = DateTime.tryParse(startTime);
    final dateStr   = dt != null
        ? '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}'
        : '';
    final statusColor = switch (status) {
      'upcoming'  => AppColors.blue,
      'completed' => AppColors.emerald,
      'cancelled' => AppColors.red,
      _           => AppColors.grey,
    };

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Container(
            width: 4.r,
            height: 36.h,
            decoration: BoxDecoration(
                color: statusColor, borderRadius: BorderRadius.circular(2.r)),
          ),
          hGap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.replaceAll('_', ' ').toUpperCase(),
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                Text(dateStr,
                    style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(status,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(color: statusColor, fontSize: 10.sp)),
          ),
        ],
      ),
    );
  }
}

// ── Training tab ──────────────────────────────────────────────────────────────

class _TrainingTab extends StatelessWidget {
  final Map<String, dynamic>? detail;
  const _TrainingTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final plans = (detail?['workout_plans'] as List?)?.cast<Map>() ?? [];
    if (plans.isEmpty) {
      return _EmptyState(
          icon: Icons.fitness_center_outlined,
          message: 'No active workout plan',
          sub: 'Send a workout plan via the plan button above');
    }
    final plan = plans.first;
    final days = (plan['days'] as List?)?.cast<Map>() ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanHeader(
            title: plan['title'] as String? ?? 'Workout Plan',
            type: plan['type'] as String? ?? '',
            color: AppColors.blue,
            icon: Icons.fitness_center_outlined,
          ),
          vGap(14),
          if (days.isEmpty)
            _EmptyInfo('No days configured for this plan')
          else
            ...days.map((day) => _DayCard(day: day)),
        ],
      ),
    );
  }
}

class _DayCard extends StatefulWidget {
  final Map day;
  const _DayCard({required this.day});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dayName  = widget.day['day_name'] as String? ?? '';
    final exercises = (widget.day['exercises'] as List?)?.cast<Map>() ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      color: AppColors.blue, size: 16.r),
                  hGap(8),
                  Expanded(
                    child: Text(dayName,
                        style: AppTextStyles.font14WhiteRegular
                            .copyWith(fontWeight: FontWeight.w600)),
                  ),
                  Text('${exercises.length} exercises',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(fontSize: 11.sp)),
                  hGap(6),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.grey,
                    size: 18.r,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(color: Colors.white10, height: 1),
            ...exercises.map((ex) {
              final name = ex['name'] as String?
                  ?? ex['exercise']?['name'] as String? ?? '';
              final sets = ex['sets'] ?? '?';
              final reps = ex['reps'] ?? '?';
              return Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(Icons.sports_gymnastics,
                        color: AppColors.teal, size: 14.r),
                    hGap(8),
                    Expanded(
                      child: Text(name,
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(color: Colors.white70)),
                    ),
                    Text('$sets × $reps',
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(color: AppColors.blue, fontSize: 11.sp)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

// ── Nutrition tab ─────────────────────────────────────────────────────────────

class _NutritionTab extends StatelessWidget {
  final Map<String, dynamic>? detail;
  const _NutritionTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final plans = (detail?['nutrition_plans'] as List?)?.cast<Map>() ?? [];
    if (plans.isEmpty) {
      return _EmptyState(
          icon: Icons.restaurant_outlined,
          message: 'No active nutrition plan',
          sub: 'Send a nutrition plan via the plan button above');
    }
    final plan  = plans.first;
    final meals = (plan['meals'] as List?)?.cast<Map>() ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanHeader(
            title: plan['title'] as String? ?? 'Nutrition Plan',
            type: plan['type'] as String? ?? '',
            color: AppColors.emerald,
            icon: Icons.restaurant_outlined,
          ),
          vGap(10),

          // Macros row
          Row(
            children: [
              if (plan['daily_calories'] != null)
                _MacroChip('Calories',
                    '${(plan['daily_calories'] as num).toStringAsFixed(0)} kcal',
                    AppColors.red),
              if (plan['protein_g'] != null) ...[
                hGap(8),
                _MacroChip(
                    'Protein',
                    '${(plan['protein_g'] as num).toStringAsFixed(0)}g',
                    AppColors.blue),
              ],
              if (plan['carbs_g'] != null) ...[
                hGap(8),
                _MacroChip(
                    'Carbs',
                    '${(plan['carbs_g'] as num).toStringAsFixed(0)}g',
                    Colors.amber),
              ],
              if (plan['fat_g'] != null) ...[
                hGap(8),
                _MacroChip(
                    'Fat',
                    '${(plan['fat_g'] as num).toStringAsFixed(0)}g',
                    Colors.orange),
              ],
            ],
          ),
          vGap(14),

          Text('Meals', style: AppTextStyles.font16WhiteBold),
          vGap(8),
          if (meals.isEmpty)
            _EmptyInfo('No meals configured')
          else
            ...meals.map((meal) => _MealCard(meal: meal)),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.font14WhiteRegular.copyWith(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12.sp)),
          Text(label,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 9.sp)),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Map meal;
  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final name       = meal['name'] as String? ?? '';
    final timeOfDay  = meal['time_of_day'] as String? ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(_mealIcon(timeOfDay),
              color: AppColors.emerald, size: 18.r),
          hGap(10),
          Expanded(
            child: Text(name,
                style: AppTextStyles.font14WhiteRegular
                    .copyWith(color: Colors.white70)),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(timeOfDay,
                style: AppTextStyles.font14GreyRegular.copyWith(
                    color: AppColors.emerald, fontSize: 10.sp)),
          ),
        ],
      ),
    );
  }

  IconData _mealIcon(String t) => switch (t) {
        'breakfast' => Icons.free_breakfast_outlined,
        'lunch'     => Icons.lunch_dining_outlined,
        'dinner'    => Icons.dinner_dining_outlined,
        'snacks'    => Icons.apple_outlined,
        _           => Icons.restaurant_menu_outlined,
      };
}

// ── InBody tab ────────────────────────────────────────────────────────────────

class _InBodyTab extends StatelessWidget {
  final Map<String, dynamic>? detail;
  const _InBodyTab({required this.detail});

  @override
  Widget build(BuildContext context) {
    final records = (detail?['in_body_records'] as List?)?.cast<Map>() ?? [];
    if (records.isEmpty) {
      return const _EmptyState(
          icon: Icons.monitor_weight_outlined,
          message: 'No InBody records',
          sub: 'Member has not recorded any InBody measurements yet');
    }

    final latest = records.first;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest record
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.teal.withValues(alpha: 0.2),
                AppColors.teal.withValues(alpha: 0.05),
              ]),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.teal.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.monitor_weight_outlined,
                        color: AppColors.teal, size: 18.r),
                    hGap(8),
                    Text('Latest Measurement',
                        style: AppTextStyles.font14WhiteRegular
                            .copyWith(color: AppColors.teal,
                                fontWeight: FontWeight.w700)),
                    const Spacer(),
                    if (latest['recorded_at'] != null)
                      Text(_fmtDate(latest['recorded_at'] as String),
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 10.sp)),
                  ],
                ),
                vGap(12),
                Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: [
                    if (latest['weight'] != null)
                      _IbStat('Weight', '${latest['weight']} kg', AppColors.teal),
                    if (latest['body_fat_pct'] != null)
                      _IbStat('Body Fat', '${latest['body_fat_pct']}%', AppColors.red),
                    if (latest['muscle_mass'] != null)
                      _IbStat('Muscle', '${latest['muscle_mass']} kg', AppColors.emerald),
                    if (latest['bmi'] != null)
                      _IbStat('BMI', '${latest['bmi']}', AppColors.blue),
                    if (latest['visceral_fat'] != null)
                      _IbStat('Visceral Fat', '${latest['visceral_fat']}', AppColors.purple),
                    if (latest['inbody_score'] != null)
                      _IbStat('Score', '${latest['inbody_score']}', AppColors.teal),
                    if (latest['bmr'] != null)
                      _IbStat('BMR', '${latest['bmr']} kcal', AppColors.blue),
                  ],
                ),
              ],
            ),
          ),

          if (records.length > 1) ...[
            vGap(16),
            Text('History', style: AppTextStyles.font16WhiteBold),
            vGap(8),
            ...records.skip(1).map((r) => _IbHistoryRow(record: r)),
          ],
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _IbStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _IbStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.font14GreyRegular
                  .copyWith(fontSize: 9.sp, color: Colors.white38)),
          Text(value,
              style: AppTextStyles.font14WhiteRegular.copyWith(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ],
      ),
    );
  }
}

class _IbHistoryRow extends StatelessWidget {
  final Map record;
  const _IbHistoryRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final date = record['recorded_at'] as String? ?? '';
    final dt   = DateTime.tryParse(date);
    final dateStr = dt != null ? '${dt.day}/${dt.month}/${dt.year}' : '';

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: AppColors.grey, size: 16.r),
          hGap(10),
          Text(dateStr, style: AppTextStyles.font14GreyRegular),
          const Spacer(),
          if (record['weight'] != null)
            _IbChip('${record['weight']} kg', AppColors.teal),
          hGap(6),
          if (record['body_fat_pct'] != null)
            _IbChip('${record['body_fat_pct']}%', AppColors.red),
        ],
      ),
    );
  }
}

class _IbChip extends StatelessWidget {
  final String text;
  final Color color;
  const _IbChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(text,
          style: AppTextStyles.font14GreyRegular
              .copyWith(color: color, fontSize: 10.sp, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Analytics tab ─────────────────────────────────────────────────────────────

class _AnalyticsTab extends StatefulWidget {
  final String memberId;
  const _AnalyticsTab({required this.memberId});

  @override
  State<_AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<_AnalyticsTab> {
  List<Map<String, dynamic>> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final id = int.tryParse(widget.memberId) ?? 0;
      final res  = await ApiClient.get('/coach/messages/$id');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final msgs = (data['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final analytics = msgs
          .where((m) => m['type'] == 'analytics_attachment')
          .toList()
          .reversed
          .toList();
      if (mounted) setState(() { _records = analytics; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _fmtDate(String? iso) {
    final dt = DateTime.tryParse(iso ?? '');
    if (dt == null) return '';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.purple));
    }
    if (_records.isEmpty) {
      return const _EmptyState(
        icon: Icons.watch_outlined,
        message: 'No Analytics Shared',
        sub: 'Member has not shared any Smart Watch analytics yet',
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: _records.length,
      itemBuilder: (_, i) {
        final a = _records[i];
        final payload = (a['payload'] as Map<String, dynamic>?) ?? {};
        final dateStr = _fmtDate(a['sent_at'] as String?);
        return Container(
          margin: EdgeInsets.only(bottom: 14.h),
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.purple.withValues(alpha: 0.20),
              AppColors.purple.withValues(alpha: 0.05),
            ]),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('⌚', style: TextStyle(fontSize: 14.sp)),
                  hGap(8),
                  Expanded(
                    child: Text('Smart Watch Analytics',
                        style: AppTextStyles.font14WhiteRegular.copyWith(
                            color: AppColors.purple, fontWeight: FontWeight.w700)),
                  ),
                  Text(dateStr,
                      style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp)),
                ],
              ),
              vGap(10),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  if (payload['steps'] != null)
                    _IbStat('Steps', '${payload['steps']}', AppColors.purple),
                  if (payload['active_minutes'] != null)
                    _IbStat('Active', '${payload['active_minutes']} min', AppColors.blue),
                  if (payload['calories_burned'] != null)
                    _IbStat('Calories', '${payload['calories_burned']} kcal', AppColors.red),
                  if (payload['heart_rate_avg'] != null)
                    _IbStat('Avg HR', '${payload['heart_rate_avg']} bpm', AppColors.red),
                  if (payload['sleep_hours'] != null)
                    _IbStat('Sleep', '${payload['sleep_hours']} hrs', AppColors.blue),
                  if (payload['water_liters'] != null)
                    _IbStat('Water', '${payload['water_liters']} L', AppColors.teal),
                  if (payload['date'] != null)
                    _IbStat('Date', '${payload['date']}', AppColors.grey),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Messages tab — embedded chat (no Scaffold wrapper) ───────────────────────

class _MessagesTab extends StatefulWidget {
  final MemberModel member;
  final Map<String, dynamic>? detail;
  const _MessagesTab({required this.member, required this.detail});

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<_MessagesTab> {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;
  int? _memberUserId;
  Timer? _pollTimer;

  late final int _memberId;

  @override
  void initState() {
    super.initState();
    _memberId     = int.tryParse(widget.member.id ?? '0') ?? 0;
    _memberUserId = widget.detail?['user']?['id'] as int?;
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res  = await ApiClient.get('/coach/messages/$_memberId');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = (data['messages'] as List?) ?? [];
      final contact = data['contact'] as Map<String, dynamic>?;
      if (!mounted) return;
      setState(() {
        _messages    = list.cast<Map<String, dynamic>>();
        _memberUserId ??= contact?['id'] as int?;
        _loading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _poll() async {
    if (!mounted || _sending) return;
    try {
      final res  = await ApiClient.get('/coach/messages/$_memberId');
      final data = res['data'] as Map<String, dynamic>? ?? {};
      final list = (data['messages'] as List?) ?? [];
      final fetched = list.cast<Map<String, dynamic>>();
      if (!mounted) return;
      final latestId = fetched.isNotEmpty ? fetched.last['id'] : -1;
      final currentId = _messages.isNotEmpty ? _messages.last['id'] : -1;
      if (fetched.length != _messages.length || latestId != currentId) {
        final hasNew = fetched.length > _messages.length;
        final wasAtBottom = _scroll.hasClients &&
            _scroll.position.pixels >=
                _scroll.position.maxScrollExtent - 120;
        setState(() => _messages = fetched);
        if (wasAtBottom || hasNew) _scrollToBottom();
      }
    } catch (_) {}
  }

  Future<void> _send([String? text]) async {
    final body = (text ?? _ctrl.text).trim();
    if (body.isEmpty || _sending) return;
    _ctrl.clear();
    setState(() {
      _sending = true;
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'body': body,
        'type': 'text',
        'sender_role': 'coach',
        'is_me': true,
        'sent_at': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();
    try {
      await ApiClient.post('/coach/messages', {
        'receiver_id': _memberUserId,
        'body': body,
      });
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  void _showSendPlan() {
    if (_memberUserId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SendPlanSheet(
          memberUserId: _memberUserId!,
          memberName: widget.member.name ?? 'Member',
          onSent: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Plan sent to ${widget.member.name}! ✅'),
              backgroundColor: AppColors.emerald,
              behavior: SnackBarBehavior.floating,
            ));
            _load();
          },
        ),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Send Plan button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          color: AppColors.secondary,
          child: Row(
            children: [
              Icon(Icons.note_add_outlined, color: AppColors.emerald, size: 16.r),
              hGap(6),
              GestureDetector(
                onTap: _showSendPlan,
                child: Text('Send Plan',
                    style: AppTextStyles.font14GreyRegular.copyWith(
                        color: AppColors.emerald, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text('${_messages.length} messages',
                  style: AppTextStyles.font14GreyRegular
                      .copyWith(fontSize: 11.sp)),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white10),

        // Message list
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.teal))
              : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              color: AppColors.grey, size: 40.r),
                          vGap(12),
                          Text('No messages yet',
                              style: AppTextStyles.font14GreyRegular),
                          vGap(6),
                          Text('Start the conversation below',
                              style: AppTextStyles.font14GreyRegular
                                  .copyWith(fontSize: 11.sp)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 8.h),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _EmbeddedMsgBubble(
                        msg: _messages[i],
                        onMakePlan: _showSendPlan,
                        onSend: _send,
                      ),
                    ),
        ),

        // Input bar
        SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            color: AppColors.secondary,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      hintStyle: AppTextStyles.font14GreyRegular,
                      filled: true,
                      fillColor: AppColors.primary,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ),
                hGap(8),
                GestureDetector(
                  onTap: _sending ? null : () => _send(),
                  child: Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                        color: AppColors.teal, shape: BoxShape.circle),
                    child: _sending
                        ? Padding(
                            padding: EdgeInsets.all(10.r),
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(Icons.send_rounded,
                            color: Colors.white, size: 18.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EmbeddedMsgBubble extends StatefulWidget {
  final Map<String, dynamic> msg;
  final VoidCallback onMakePlan;
  final void Function(String) onSend;
  const _EmbeddedMsgBubble({
    required this.msg,
    required this.onMakePlan,
    required this.onSend,
  });

  @override
  State<_EmbeddedMsgBubble> createState() => _EmbeddedMsgBubbleState();
}

class _EmbeddedMsgBubbleState extends State<_EmbeddedMsgBubble> {
  bool _expanded = true;

  String _fmtTime(String? iso) {
    final dt = DateTime.tryParse(iso ?? '') ?? DateTime.now();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final msg     = widget.msg;
    final isMe    = msg['sender_role'] == 'coach' || msg['is_me'] == true;
    final body    = msg['body'] as String? ?? '';
    final type    = msg['type'] as String? ?? 'text';
    final payload = (msg['payload'] as Map<String, dynamic>?) ?? {};
    final timeStr = _fmtTime(msg['sent_at'] as String?);

    // ── Deleted ──────────────────────────────────────────────────────────────
    if (type == 'deleted') {
      return Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, color: AppColors.grey, size: 12.r),
                hGap(5),
                Text('Message deleted',
                    style: AppTextStyles.font14GreyRegular.copyWith(
                        fontSize: 11.sp, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      );
    }

    // ── InBody / Analytics rich card ─────────────────────────────────────────
    if (type == 'inbody_attachment' || type == 'analytics_attachment') {
      final isInBody = type == 'inbody_attachment';
      final color    = isInBody ? AppColors.teal : AppColors.purple;
      final icon     = isInBody ? Icons.monitor_weight_outlined : Icons.watch_outlined;
      final label    = isMe
          ? (isInBody ? 'In-Body Results Shared' : 'Smart Watch Analytics Shared')
          : (isInBody ? 'Member sent In-Body Results' : 'Member sent Smart Watch Analytics');

      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 0.85.sw),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                color.withValues(alpha: 0.22),
                color.withValues(alpha: 0.08),
              ]),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (tappable to toggle)
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 12.h, 8.w, 8.h),
                    child: Row(
                      children: [
                        Icon(icon, color: color, size: 15.r),
                        hGap(6),
                        Expanded(
                          child: Text(label,
                              style: AppTextStyles.font14WhiteRegular.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp)),
                        ),
                        Text(timeStr,
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(fontSize: 10.sp)),
                        hGap(4),
                        Icon(
                          _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: color, size: 18.r,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_expanded) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        if (isInBody) ...[
                          if (payload['weight'] != null)
                            _IbStat('Weight', '${payload['weight']} kg', AppColors.teal),
                          if (payload['body_fat_pct'] != null)
                            _IbStat('Body Fat', '${payload['body_fat_pct']}%', AppColors.red),
                          if (payload['muscle_mass'] != null)
                            _IbStat('Muscle', '${payload['muscle_mass']} kg', AppColors.emerald),
                          if (payload['bmi'] != null)
                            _IbStat('BMI', '${payload['bmi']}', AppColors.blue),
                          if (payload['visceral_fat'] != null)
                            _IbStat('Visceral', '${payload['visceral_fat']}', AppColors.purple),
                          if (payload['inbody_score'] != null)
                            _IbStat('Score', '${payload['inbody_score']}', AppColors.teal),
                          if (payload['bmr'] != null)
                            _IbStat('BMR', '${payload['bmr']} kcal', AppColors.blue),
                        ] else ...[
                          if (payload['sleep_hours'] != null)
                            _IbStat('Sleep', '${payload['sleep_hours']} hrs', AppColors.blue),
                          if (payload['water_liters'] != null)
                            _IbStat('Water', '${payload['water_liters']} L', AppColors.teal),
                          if (payload['steps'] != null)
                            _IbStat('Steps', '${payload['steps']}', AppColors.purple),
                          if (payload['active_minutes'] != null)
                            _IbStat('Active', '${payload['active_minutes']} min', AppColors.blue),
                          if (payload['calories_burned'] != null)
                            _IbStat('Calories', '${payload['calories_burned']} kcal', AppColors.red),
                          if (payload['heart_rate_avg'] != null)
                            _IbStat('Avg HR', '${payload['heart_rate_avg']} bpm', AppColors.red),
                        ],
                      ],
                    ),
                  ),
                  // Action buttons (only when viewing member's sent data as coach)
                  if (!isMe) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 8.h),
                      child: _ActionBtn(
                        label: '📋 Make a plan from this data',
                        color: color,
                        onTap: widget.onMakePlan,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 12.h),
                      child: _ActionBtn(
                        label: '💬 Reply to member',
                        color: AppColors.blue,
                        onTap: () => widget.onSend(
                          isInBody
                              ? 'I reviewed your In-Body results 📊 '
                              : 'I checked your Smart Watch Analytics ⌚ ',
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      );
    }

    // ── Plan card ─────────────────────────────────────────────────────────────
    if (type == 'workout_plan' || type == 'nutrition_plan') {
      final isWorkout = type == 'workout_plan';
      final color     = isWorkout ? AppColors.blue : AppColors.emerald;
      final days      = (payload['days'] as List?)?.cast<Map>() ?? [];
      final meals     = (payload['meals'] as List?)?.cast<Map>() ?? [];
      final title     = payload['title'] as String? ?? body;
      return Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(maxWidth: 0.82.sw),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                color.withValues(alpha: 0.20),
                color.withValues(alpha: 0.06),
              ]),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: color.withValues(alpha: 0.45)),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isWorkout ? Icons.fitness_center_outlined : Icons.restaurant_outlined,
                          color: color, size: 16.r),
                      hGap(8),
                      Expanded(
                        child: Text(title,
                            style: AppTextStyles.font14WhiteRegular
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                      Text(timeStr,
                          style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 10.sp)),
                    ],
                  ),
                  vGap(8),
                  if (isWorkout)
                    ...days.take(3).map((d) => _PlanPreviewLine(
                        icon: Icons.calendar_today_outlined,
                        text: d['day_name'] as String? ?? '',
                        color: color))
                  else
                    ...meals.take(3).map((m) => _PlanPreviewLine(
                        icon: Icons.restaurant_menu_outlined,
                        text: m['name'] as String? ?? '',
                        color: color)),
                  if (msg['is_applied'] == true) ...[
                    vGap(6),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.emerald, size: 13.r),
                        hGap(4),
                        Text('Member applied this plan',
                            style: AppTextStyles.font14GreyRegular.copyWith(
                                color: AppColors.emerald,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Normal text bubble ────────────────────────────────────────────────────
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12.r,
              backgroundColor: AppColors.blue.withValues(alpha: 0.2),
              child: Icon(Icons.person, size: 12.r, color: AppColors.blue),
            ),
            hGap(6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.teal.withValues(alpha: 0.85)
                        : AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14.r),
                      topRight: Radius.circular(14.r),
                      bottomLeft: isMe
                          ? Radius.circular(14.r)
                          : Radius.circular(4.r),
                      bottomRight: isMe
                          ? Radius.circular(4.r)
                          : Radius.circular(14.r),
                    ),
                    border: isMe ? null : Border.all(color: Colors.white12),
                  ),
                  child: Text(body,
                      style: AppTextStyles.font14WhiteRegular.copyWith(
                          height: 1.4, color: Colors.white)),
                ),
                vGap(2),
                Text(timeStr,
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 9.sp)),
              ],
            ),
          ),
          if (isMe) hGap(6),
        ],
      ),
    );
  }
}

// ── Embedded message helper widgets ──────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 9.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          textStyle: TextStyle(fontSize: 12.sp),
        ),
        child: Text(label),
      ),
    );
  }
}

class _PlanPreviewLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _PlanPreviewLine({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 3.h),
      child: Row(
        children: [
          Icon(icon, color: color, size: 11.r),
          hGap(5),
          Expanded(
            child: Text(text,
                style: AppTextStyles.font14GreyRegular
                    .copyWith(fontSize: 11.sp, color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _PlanHeader extends StatelessWidget {
  final String title;
  final String type;
  final Color color;
  final IconData icon;
  const _PlanHeader({required this.title, required this.type,
      required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.r),
          hGap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.font14WhiteRegular
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(type.toUpperCase(),
                    style: AppTextStyles.font14GreyRegular
                        .copyWith(fontSize: 10.sp, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyInfo extends StatelessWidget {
  final String message;
  const _EmptyInfo(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(message,
          style: AppTextStyles.font14GreyRegular,
          textAlign: TextAlign.center),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyState({required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.grey, size: 52.r),
            vGap(16),
            Text(message, style: AppTextStyles.font16WhiteBold,
                textAlign: TextAlign.center),
            vGap(8),
            Text(sub, style: AppTextStyles.font14GreyRegular,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(label,
          style: AppTextStyles.font14GreyRegular.copyWith(
              color: color, fontSize: 10.sp, fontWeight: FontWeight.w600)),
    );
  }
}
