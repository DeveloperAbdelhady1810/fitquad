import 'package:flutter/material.dart';

import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/features/coach/calender/widgets/week_tab_bar_view.dart';

import '../../../../generated/l10n.dart';
import 'day_tab_bar_view.dart';

class CalenderTab extends StatelessWidget {
  const CalenderTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          CustomTabBar(
            isSecondary: true,
            tabs: [Text(s.day), Text(s.week), Text(s.month)],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: TabBarView(
                children: [DayTabBarView(), WeekTabBarView(
                  weekSessions: {
                    'Mon': [],
                    'Tue': [],
                    'Wed': [],
                    'Thu': [],
                    'Fri': [],
                    'Sat': [],
                    'Sun': [],
                  },
                ), DayTabBarView()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
