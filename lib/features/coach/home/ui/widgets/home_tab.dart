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
import 'package:gym_app/features/member/home/manager/bottom_nav_bar_cubit.dart';

import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
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

    return BlocBuilder<CoachCubit, CoachState>(
      builder: (context, state) {
        final loaded = state is CoachesLoaded ? state : null;

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Stats Row ──
              Row(
                children: [
                  _StatCard(
                    label: "Today's\nSessions",
                    value: '${loaded?.todaySessions ?? '--'}',
                    icon: Icons.calendar_today,
                    color: AppColors.blue,
                  ),
                  hGap(10),
                  _StatCard(
                    label: 'Active\nClients',
                    value: '${loaded?.activeMembers ?? '--'}',
                    icon: Icons.people_outline,
                    color: AppColors.teal,
                  ),
                  hGap(10),
                  _StatCard(
                    label: 'Monthly\nEarnings',
                    value: loaded != null
                        ? '${loaded.monthlyEarnings.toStringAsFixed(0)} EGP'
                        : '--',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.emerald,
                  ),
                  hGap(10),
                  _StatCard(
                    label: 'Rating',
                    value: loaded != null
                        ? loaded.rating > 0
                            ? loaded.rating.toStringAsFixed(1)
                            : 'N/A'
                        : '--',
                    icon: Icons.star_outline,
                    color: Colors.amber,
                  ),
                ],
              ),

              vGap(20),

              // ── Today's Schedule ──
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

              if (loaded != null && loaded.sessions.isNotEmpty)
                SizedBox(
                  height: 160.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: loaded.sessions.length.clamp(0, 5),
                    separatorBuilder: (_, __) => hGap(10),
                    itemBuilder: (context, index) {
                      final session = loaded.sessions[index];
                      return Container(
                        width: 180.w,
                        decoration: AppDecorations.containerDecoration,
                        padding: EdgeInsets.all(12.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${session.startTime?.timeOnly ?? '--'} - ${session.endTime?.timeOnly ?? '--'}',
                                    style: AppTextStyles.font14GreyRegular
                                        .copyWith(fontSize: 11.sp),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: (session.status?.color ??
                                            AppColors.teal)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    session.status?.label(context) ?? '',
                                    style: AppTextStyles.font14GreyRegular
                                        .copyWith(
                                      fontSize: 10.sp,
                                      color: session.status?.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            vGap(8),
                            Text(
                              session.type ?? '',
                              style: AppTextStyles.font16WhiteBold
                                  .copyWith(fontSize: 13.sp),
                            ),
                            vGap(4),
                            Text(
                              session.memberModel?.name ?? '',
                              style: AppTextStyles.font14GreyRegular,
                            ),
                            vGap(4),
                            Text(
                              '📍 ${session.location ?? ''}',
                              style: AppTextStyles.font14GreyRegular
                                  .copyWith(fontSize: 11.sp),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                _EmptyCard(
                  icon: Icons.event_available_outlined,
                  message: 'No sessions scheduled for today',
                ),

              vGap(20),

              // ── Client Alerts ──
              if (loaded != null && loaded.clientAlerts.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined,
                        color: Colors.orange, size: 18.r),
                    hGap(6),
                    Text('Client Alerts', style: AppTextStyles.font16WhiteBold),
                    hGap(6),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '${loaded.clientAlerts.length}',
                        style: AppTextStyles.font14GreyRegular.copyWith(
                          color: Colors.orange,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                vGap(10),
                ...loaded.clientAlerts.map((alert) {
                  final type = alert['type'] as String? ?? '';
                  final name = alert['member_name'] as String? ?? '';
                  final msg = alert['message'] as String? ?? '';
                  final icon = type == 'inactive'
                      ? Icons.warning_amber_rounded
                      : type == 'expiring'
                          ? Icons.credit_card_off_outlined
                          : Icons.emoji_events_outlined;
                  final color = type == 'inactive'
                      ? Colors.red
                      : type == 'expiring'
                          ? Colors.orange
                          : AppColors.teal;
                  return GestureDetector(
                    onTap: () {
                      final member = loaded.allMembers.where(
                        (m) => m.name == name,
                      ).firstOrNull;
                      if (member != null) {
                        context.push(MemberProfileScreen.routeName,
                            extra: member);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: color.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 20.r),
                          hGap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: AppTextStyles.font14WhiteRegular
                                        .copyWith(
                                            fontWeight: FontWeight.w600)),
                                Text(msg,
                                    style:
                                        AppTextStyles.font14GreyRegular
                                            .copyWith(fontSize: 11.sp)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: AppColors.grey, size: 16.r),
                        ],
                      ),
                    ),
                  );
                }),
                vGap(10),
              ],

              // ── Members to Follow Up ──
              Text(s.members_to_follow_up,
                  style: AppTextStyles.font16WhiteBold),
              vGap(10),
              if (loaded != null && loaded.allMembers.isNotEmpty)
                SizedBox(
                  height: 60.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: loaded.allMembers.length.clamp(0, 8),
                    separatorBuilder: (_, __) => hGap(10),
                    itemBuilder: (context, index) {
                      final member = loaded.allMembers[index];
                      return GestureDetector(
                        onTap: () => context.push(
                            MemberProfileScreen.routeName,
                            extra: member),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor:
                                  AppColors.teal.withValues(alpha: 0.2),
                              child: Text(
                                (member.name?.isNotEmpty == true
                                        ? member.name![0]
                                        : '?')
                                    .toUpperCase(),
                                style: AppTextStyles.font14WhiteRegular
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            vGap(4),
                            Text(
                              member.name?.split(' ').first ?? '',
                              style: AppTextStyles.font14GreyRegular
                                  .copyWith(fontSize: 10.sp),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              else
                _EmptyCard(
                  icon: Icons.people_outline,
                  message: 'No clients yet',
                ),

              vGap(20),

              // ── Quick Actions ──
              Text('Quick Actions', style: AppTextStyles.font16WhiteBold),
              vGap(10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _ActionTile(
                    icon: Icons.fitness_center,
                    color: AppColors.blue,
                    label: s.create_plan,
                    onTap: () => showChoosePlanDialog(context),
                  ),
                  _ActionTile(
                    icon: Icons.restaurant_menu_outlined,
                    color: AppColors.emerald,
                    label: s.nutrition,
                    onTap: () => showNutritionDialog(context),
                  ),
                  _ActionTile(
                    icon: Icons.campaign_outlined,
                    color: Colors.purple,
                    label: s.broadcast,
                    onTap: () => showBroadcastDialog(context),
                  ),
                  _ActionTile(
                    icon: Icons.add_circle_outline,
                    color: Colors.orange,
                    label: s.add_session,
                    onTap: () => showAddSessionDialog(
                      context,
                      dateController,
                      timeController,
                    ),
                  ),
                ],
              ),
              vGap(20),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
        decoration: AppDecorations.containerDecoration.copyWith(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20.r),
            vGap(4),
            Text(
              value,
              style: AppTextStyles.font14WhiteRegular.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTextStyles.font14GreyRegular.copyWith(fontSize: 9.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.containerDecoration.copyWith(
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.r),
            ),
            hGap(8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.font14WhiteRegular.copyWith(fontSize: 11.sp),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: AppDecorations.containerDecoration.copyWith(
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.grey, size: 28.r),
          vGap(8),
          Text(message, style: AppTextStyles.font14GreyRegular),
        ],
      ),
    );
  }
}
