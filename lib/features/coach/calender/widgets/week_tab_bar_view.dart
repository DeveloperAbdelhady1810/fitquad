import 'package:flutter/material.dart';
import 'package:gym_app/features/coach/home/manager/date_time_extensions.dart';

import '../../home/data/models/session_model.dart';
import '../../home/manager/status_ext.dart';
import 'day_tab_bar_view.dart';

class WeekTabBarView extends StatefulWidget {
  final Map<String, List<SessionModel>> weekSessions; // key = 'Mon', 'Tue', ...
  const WeekTabBarView({super.key, required this.weekSessions});

  @override
  State<WeekTabBarView> createState() => _WeekTabBarViewState();
}

class _WeekTabBarViewState extends State<WeekTabBarView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: weekDays
              .map((day) => Tab(
            child: Text(
              day,
              style: TextStyle(color: Colors.white),
            ),
          ))
              .toList(),
          isScrollable: true,
          indicatorColor: Colors.greenAccent,
        ),
        const SizedBox(height: 10),

        // TabBarView لكل يوم
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: weekDays.map((day) {
              final sessions = widget.weekSessions[day] ?? [];
              if (sessions.isEmpty) {
                return const Center(
                  child: Text(
                    'No sessions',
                    style: TextStyle(color: Colors.white38),
                  ),
                );
              }
              return ListView.separated(
                itemCount: sessions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final isLast = index == sessions.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                        child: Column(
                          children: [
                            SessionDot(isOngoing: session.status == SessionStatus.ongoing),
                            if (!isLast)
                              Container(
                                width: 3,
                                height: 100,
                                color: session.status == SessionStatus.completed
                                    ? Colors.grey.withValues(alpha:0.3)
                                    : session.status == SessionStatus.ongoing
                                    ? Colors.blueAccent.withValues(alpha:0.5)
                                    : Colors.grey.withValues(alpha:0.5),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Opacity(
                          opacity: session.status?.isDisabled == true ? 0.5 : 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: session.status?.backgroundColor,
                              border: Border.all(
                                  color: session.status!.borderColor, width: 1.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${session.startTime?.timeOnly ?? '--'} - ${session.endTime?.timeOnly ?? '--'}',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        session.status?.label(context) ?? '',
                                        style: TextStyle(
                                          color: session.status?.color,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(session.type ?? ' ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                Text(session.memberModel?.name ?? '', style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 5),
                                Text('• ${session.location}', style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}