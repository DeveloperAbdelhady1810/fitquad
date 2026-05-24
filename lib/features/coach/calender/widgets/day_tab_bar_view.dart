import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/features/coach/home/manager/date_time_extensions.dart';
import 'package:gym_app/features/coach/home/manager/status_ext.dart';

import '../../../../core/helpers/app_decoration.dart';
import '../../../../core/helpers/spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../home/manager/coach_cubit.dart';

class DayTabBarView extends StatelessWidget {
  const DayTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CoachCubit()..getCoachSessions('1'),
      child: BlocBuilder<CoachCubit, CoachState>(
        builder: (context, state) {
          if (state is CoachLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueGrey),
            );
          }

          if (state is CoachesLoaded) {
            return ListView.separated(
              itemCount: state.sessions.length,
              separatorBuilder: (_, __) => vGap(10),
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                final isLast = index == state.sessions.length ;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      child: Column(
                        children: [
                           SessionDot(isOngoing: session.status == SessionStatus.ongoing,),
                          if (!isLast)
                            Container(
                              width: 3,
                              height: 150,
                              color: session.status == SessionStatus.completed
                                  ? Colors.grey.withValues(alpha: 0.3)
                                  : session.status == SessionStatus.ongoing
                                  ? Colors.blueAccent.withValues(alpha: 0.5)
                                  : Colors.grey.withValues(alpha: 0.5),
                            ),
                        ],
                      ),
                    ),


                    hGap(8),

                    Expanded(
                      child: Opacity(
                        opacity: session.status?.isDisabled == true ? 0.5 : 1,
                        child: Container(
                          decoration: AppDecorations.containerDecoration.copyWith(
                            color: session.status?.backgroundColor,
                            border: Border.all(
                              color: session.status!.borderColor,
                              width: 1.2,
                            )
                          ),
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
                                    decoration: AppDecorations.containerDecoration,
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      session.status?.label(context) ?? '',
                                      style: AppTextStyles.font14GreyRegular.copyWith(
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
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          if (state is CoachError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class SessionDot extends StatelessWidget {
  final bool isOngoing;
  const SessionDot({super.key ,this.isOngoing=false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration:  BoxDecoration(
        shape: BoxShape.circle,
        color: isOngoing ? AppColors.blue: AppColors.grey.withValues(alpha: 0.5),
      ),
    );
  }
}
