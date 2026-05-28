import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/features/coach/home/manager/coach_cubit.dart';
import 'package:gym_app/features/coach/home/manager/date_time_extensions.dart';
import 'package:gym_app/features/coach/home/manager/status_ext.dart';
import 'package:gym_app/features/coach/home/data/models/session_model.dart';

import '../../../../generated/l10n.dart';

class CalenderTab extends StatefulWidget {
  const CalenderTab({super.key});

  @override
  State<CalenderTab> createState() => _CalenderTabState();
}

class _CalenderTabState extends State<CalenderTab> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          CustomTabBar(
            isSecondary: true,
            tabs: [Text(s.day), Text(s.week)],
          ),
          Expanded(
            child: BlocBuilder<CoachCubit, CoachState>(
              builder: (context, state) {
                final sessions = state is CoachesLoaded ? state.sessions : <SessionModel>[];

                // Selected day's sessions
                final selSess = sessions.where((s) {
                  final t = s.startTime;
                  return t != null &&
                      t.year == _selectedDay.year &&
                      t.month == _selectedDay.month &&
                      t.day == _selectedDay.day;
                }).toList();

                // Week sessions grouped Mon–Sun
                final today2   = DateTime.now();
                final weekStart = today2.subtract(
                    Duration(days: today2.weekday - 1));
                final Map<String, List<SessionModel>> weekMap = {
                  'Mon': [], 'Tue': [], 'Wed': [],
                  'Thu': [], 'Fri': [], 'Sat': [], 'Sun': [],
                };
                const dayNames = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                for (final sess in sessions) {
                  final t = sess.startTime;
                  if (t == null) continue;
                  for (int i = 0; i < 7; i++) {
                    final d = weekStart.add(Duration(days: i));
                    if (t.year == d.year && t.month == d.month && t.day == d.day) {
                      weekMap[dayNames[i]]!.add(sess);
                    }
                  }
                }

                return TabBarView(
                  children: [
                    _DayView(
                      selectedDay: _selectedDay,
                      sessions: selSess,
                      onDayChanged: (d) => setState(() => _selectedDay = d),
                    ),
                    _WeekView(weekSessions: weekMap),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Day view ──────────────────────────────────────────────────────────────────

class _DayView extends StatelessWidget {
  final DateTime selectedDay;
  final List<SessionModel> sessions;
  final ValueChanged<DateTime> onDayChanged;

  const _DayView({
    required this.selectedDay,
    required this.sessions,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Date picker row ─────────────────────────────────────
        Container(
          color: AppColors.secondary,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: AppColors.grey, size: 20.r),
                onPressed: () => onDayChanged(
                    selectedDay.subtract(const Duration(days: 1))),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDay,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (d != null) onDayChanged(d);
                  },
                  child: Column(
                    children: [
                      Text(
                        _dayLabel(selectedDay),
                        style: AppTextStyles.font16WhiteBold
                            .copyWith(fontSize: 14.sp),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _dateStr(selectedDay),
                        style: AppTextStyles.font14GreyRegular
                            .copyWith(fontSize: 11.sp),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.grey, size: 20.r),
                onPressed: () =>
                    onDayChanged(selectedDay.add(const Duration(days: 1))),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),

        // ── Session list ────────────────────────────────────────
        Expanded(
          child: sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available_outlined,
                          color: AppColors.grey, size: 40.r),
                      vGap(12),
                      Text('No sessions on this day',
                          style: AppTextStyles.font14GreyRegular),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(12.r),
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => vGap(8),
                  itemBuilder: (_, i) => _SessionCard(session: sessions[i]),
                ),
        ),
      ],
    );
  }

  String _dayLabel(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return days[d.weekday - 1];
  }

  String _dateStr(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec'
  ];
}

// ── Week view ─────────────────────────────────────────────────────────────────

class _WeekView extends StatefulWidget {
  final Map<String, List<SessionModel>> weekSessions;
  const _WeekView({required this.weekSessions});

  @override
  State<_WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<_WeekView> with SingleTickerProviderStateMixin {
  late final TabController _tab;
  static const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  @override
  void initState() {
    super.initState();
    final todayIdx = DateTime.now().weekday - 1;
    _tab = TabController(length: 7, vsync: this, initialIndex: todayIdx);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tab,
          isScrollable: true,
          indicatorColor: AppColors.teal,
          labelColor: AppColors.teal,
          unselectedLabelColor: AppColors.grey,
          labelStyle: AppTextStyles.font14GreyRegular
              .copyWith(fontWeight: FontWeight.w600, fontSize: 12.sp),
          tabs: _days.map((d) {
            final count = widget.weekSessions[d]?.length ?? 0;
            return Tab(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Text(d),
                  if (count > 0)
                    Positioned(
                      right: -6,
                      top: -2,
                      child: Container(
                        width: 14.r,
                        height: 14.r,
                        decoration: const BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text('$count',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: _days.map((d) {
              final daySessions = widget.weekSessions[d] ?? [];
              if (daySessions.isEmpty) {
                return Center(
                  child: Text('No sessions on $d',
                      style: AppTextStyles.font14GreyRegular),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.all(12.r),
                itemCount: daySessions.length,
                separatorBuilder: (_, __) => vGap(8),
                itemBuilder: (_, i) =>
                    _SessionCard(session: daySessions[i]),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final borderColor = session.status?.color ?? AppColors.teal;
    final memberName  = session.memberModel?.name ?? '';
    final type        = (session.type ?? '').replaceAll('_', ' ');
    final timeStr     =
        '${session.startTime?.timeOnly ?? '--'} — ${session.endTime?.timeOnly ?? '--'}';

    return Container(
      decoration: AppDecorations.containerDecoration.copyWith(
        color: session.status?.backgroundColor ??
            AppColors.secondary.withValues(alpha: 0.8),
        border: Border.all(color: borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(12.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Column(
            children: [
              Container(
                width: 10.r,
                height: 10.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: borderColor,
                ),
              ),
            ],
          ),
          hGap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(timeStr,
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: borderColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        session.status?.label(context) ?? '',
                        style: AppTextStyles.font14GreyRegular.copyWith(
                            fontSize: 10.sp, color: borderColor),
                      ),
                    ),
                  ],
                ),
                vGap(6),
                Text(type.toUpperCase(),
                    style: AppTextStyles.font16WhiteBold
                        .copyWith(fontSize: 13.sp)),
                vGap(3),
                if (memberName.isNotEmpty)
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          color: AppColors.grey, size: 13.r),
                      hGap(4),
                      Text(memberName,
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 12.sp)),
                    ],
                  ),
                if (session.location != null && session.location!.isNotEmpty)
                  ...[
                    vGap(2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppColors.grey, size: 13.r),
                        hGap(4),
                        Text(session.location!,
                            style: AppTextStyles.font14GreyRegular
                                .copyWith(fontSize: 11.sp)),
                      ],
                    ),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
