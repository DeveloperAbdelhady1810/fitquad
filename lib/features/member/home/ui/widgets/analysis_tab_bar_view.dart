import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/ui/widgets/line_chart.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

class AnalysisTabBarView extends StatelessWidget {
  const AnalysisTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        if (state is MemberLoading) {
          return const CircularProgressIndicator();
        }

        if (state is MemberLoaded) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: AppDecorations.containerDecoration.copyWith(
                    border: Border(
                      top: BorderSide(color: AppColors.emerald, width: 7),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: LineChartWidget(
                    spots: const [
                      FlSpot(1, 2),
                      FlSpot(2, 4),
                      FlSpot(3, 3),
                      FlSpot(4, 5),
                    ],
                    minX: 1,
                    maxX: 4,
                    minY: 0,
                    maxY: 6,
                    bottomTitles: {1: 'Sat', 2: 'Sun', 3: 'Mon', 4: 'Tue'},
                  ),
                ),
                vGap(10),
                Container(
                  decoration: AppDecorations.containerDecoration,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.emerald.withValues(alpha: 0.3),
                      child: Icon(Icons.calendar_month, color: AppColors.emerald),
                    ),
                    subtitle: Text(
                      "Based on your training plan and 320kcal avg. burn/session, you're on track to hit this weight in 4 weeks.",
                      style: AppTextStyles.font14GreyRegular,
                    ),
                    title: Text(
                      'Projected: ${state.member.weight} kg',
                      style: AppTextStyles.font16WhiteBold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
