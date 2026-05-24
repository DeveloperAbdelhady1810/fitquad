import 'package:fl_chart/fl_chart.dart' show FlSpot;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/features/coach/home/manager/date_time_extensions.dart';
import 'package:gym_app/features/coach/home/manager/status_ext.dart';
import 'package:gym_app/features/coach/home/ui/widgets/add_session_dialog.dart';
import 'package:gym_app/features/coach/home/ui/widgets/follow_up_container.dart';
import 'package:gym_app/features/member/home/manager/bottom_nav_bar_cubit.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../../../member/home/ui/widgets/line_chart.dart';
import '../../manager/coach_cubit.dart';
import 'broadcast_dialog.dart';
import 'choose_plan_dialog.dart';
import 'member_profile_screen.dart';
import 'nutrition_dialog.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,

              childAspectRatio: 1.5,
              padding: const EdgeInsets.all(16),
              children: [
                _buildItem(
                  title: 'Item 1',
                  subTitle: 'sub',
                  color: Colors.blue,
                  num: 1,
                ),
                _buildItem(
                  title: 'Item 1',
                  subTitle: 'sub',
                  color: Colors.blue,
                  num: 1,
                ),
                _buildItem(
                  title: 'Item 1',
                  subTitle: 'sub',
                  color: Colors.blue,
                  num: 1,
                ),
                _buildItem(
                  title: 'Item 1',
                  subTitle: 'sub',
                  color: Colors.blue,
                  num: 1,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(s.todays_sessions, style: AppTextStyles.font16WhiteBold),
              TextButton(
                onPressed: () =>
                    context.read<BottomNavBarCubit>().changeIndex(2),
                child: Text(
                  s.view_full_schedule,
                  style: AppTextStyles.font16WhiteBold.copyWith(
                    color: AppColors.blue,
                  ),
                ),
              ),
            ],
          ),

          BlocBuilder<CoachCubit, CoachState>(
            builder: (context, state) {
              if (state is CoachesLoaded) {
                return SizedBox(
                  height: 200,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];

                      return Container(
                        height: 150,
                        decoration: AppDecorations.containerDecoration,
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${session.startTime?.timeOnly ?? '--'} - ${session.endTime?.timeOnly ?? '--'}',
                                  style: AppTextStyles.font14GreyRegular,
                                ),
                                Container(
                                  decoration:
                                      AppDecorations.containerDecoration,
                                  padding: EdgeInsets.all(5),
                                  child: Text(
                                    session.status?.label(context) ?? '',
                                    style: AppTextStyles.font14GreyRegular
                                        .copyWith(
                                          fontSize: 12.sp,
                                          color: session.status?.color,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            vGap(10),

                            Text(
                              session.type ?? ' ',
                              style: AppTextStyles.font16WhiteBold,
                            ),
                            vGap(5),
                            Text(
                              session.memberModel?.name ?? '',
                              style: AppTextStyles.font14GreyRegular,
                            ),
                            vGap(5),
                            Text(
                              '• ${session.location}',
                              style: AppTextStyles.font14GreyRegular,
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => hGap(10),
                    itemCount: 2,
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          ),

          vGap(10),

          Text(s.members_to_follow_up, style: AppTextStyles.font16WhiteBold),
          vGap(10),
          BlocBuilder<CoachCubit, CoachState>(
            builder: (context, state) {
              if (state is CoachesLoaded) {
                return SizedBox(
                  height: 200,
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      return FollowUpContainer(
                        onTap: () => context.push(MemberProfileScreen.routeName ,extra: state.allMembers[index] ),
                        name: state.allMembers[index].name ?? '',
                      );
                    },
                    separatorBuilder: (context, index) => vGap(10),
                    itemCount: state.allMembers.length,
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          ),
          vGap(10),
          Container(
            width: double.infinity,
            decoration: AppDecorations.containerDecoration,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.workout_completion_rate,
                  style: AppTextStyles.font16WhiteBold,
                ),
                vGap(10),

                LineChartWidget(
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
              ],
            ),
          ),
          vGap(20),

          SizedBox(
            height: 200.h,
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 10,

              childAspectRatio: 2,
              children: [
                buildListTile(
                  icon: Icons.fitness_center,
                  color: Colors.blueAccent,
                  onTap: () => showChoosePlanDialog(context),
                  subTitle: s.create_plan,
                ),
                buildListTile(
                  icon: Icons.description_outlined,
                  color: Colors.green,
                  onTap: () => showNutritionDialog(context),
                  subTitle: s.nutrition,
                ),
                buildListTile(
                  icon: Icons.chat_bubble_outline,
                  color: Colors.purple,
                  onTap: () =>showBroadcastDialog(context),
                  subTitle: s.broadcast,
                ),
                buildListTile(
                  icon: Icons.add,
                  color: Colors.orange,
                  onTap: () => showAddSessionDialog(
                    context,
                    dateController,
                    timeController,
                  ),
                  subTitle: s.add_session,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String title,
    required String subTitle,
    required int num,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      height: 50,
      decoration: AppDecorations.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTextStyles.font16WhiteBold.copyWith(color: color),
          ),
          Text(subTitle, style: AppTextStyles.font16GreyRegular),
          Text(title, style: AppTextStyles.font14GreyRegular),
        ],
      ),
    );
  }

  Widget buildListTile({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String subTitle,
  }) {
    return Container(
      decoration: AppDecorations.containerDecoration,
      padding: EdgeInsets.all(10),
      child: ListTile(
        onTap: onTap,
        title: Icon(icon, color: color, size: 30.sp),
        subtitle: Text(
          subTitle,
          style: AppTextStyles.font14WhiteRegular,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
