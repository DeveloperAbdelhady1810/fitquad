import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/home/ui/widgets/request_sent_screen.dart';

import '../../../../../generated/l10n.dart';

class ChooseCoachScreen extends StatelessWidget {

  const ChooseCoachScreen({super.key });
  static const String routeName = '/choose_coach';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.grey),
        backgroundColor: AppColors.primary,
        title: ListTile(
          title: Text(s.find_a_coach, style: AppTextStyles.font16WhiteBold),
          subtitle: Text(
            s.select_a_pro_to_build_workout,
            style: AppTextStyles.font14GreyRegular,
          ),
        ),
      ),
      body: BlocBuilder<MemberCubit, MemberState>(
        builder: (context, state) {
          if (state is MemberLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.grey),
            );
          }
          if (state is MemberError) {
            return Center(
              child: Text(
                state.message,
                style: AppTextStyles.font16GreyRegular,
              ),
            );
          }

          if (state is CoachLoaded) {
            return ListView.separated(
              itemBuilder: (context, index) {
                final coach = state.coaches[index];
                return Container(
                  margin: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  decoration: AppDecorations.containerDecoration,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 25.r,
                          child: Text(
                            getInitials(coach.name),
                            style: AppTextStyles.font16WhiteBold,
                          ),
                        ),
                        title: Text(
                          coach.name,
                          style: AppTextStyles.font16WhiteBold,
                        ),
                        subtitle: Text(
                          coach.jobTitle,
                          style: AppTextStyles.font14GreyRegular.copyWith(
                            color: AppColors.emerald,
                          ),
                        ),
                        trailing: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              decoration: AppDecorations.containerDecoration,
                              child: Text(
                                '⭐ ${coach.rating}',
                                style: AppTextStyles.font14GreyRegular.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            Text(
                              ' ${coach.reviewsCount} Reviews',
                              style: AppTextStyles.font14GreyRegular,
                            ),
                          ],
                        ),
                      ),
                      vGap(20),
                      Text(coach.bio, style: AppTextStyles.font16GreyRegular),
                      const Spacer(),
                      const Divider(),
                      ListTile(
                        title: Text(
                          s.price.toUpperCase(),
                          style: AppTextStyles.font14GreyRegular,
                        ),
                        subtitle: Text(
                          coach.price.toString(),
                          style: AppTextStyles.font16WhiteBold,
                        ),
                        trailing: SizedBox(
                          width: 120,
                          child: CustomButton(
                            text: s.hire_coach,
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.all(16),
                                child: Container(
                                  decoration: AppDecorations.containerDecoration.copyWith(color: AppColors.primary),
                                  padding: EdgeInsets.all(10),
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: Text(
                                          s.confirm_request,
                                          style: AppTextStyles.font16WhiteBold,
                                        ),
                                        subtitle: Text(
                                          "${s.you_are_about_to_hire_coach} ${coach.name}",
                                          style: AppTextStyles.font14GreyRegular,
                                        ),
                                        trailing: IconButton(
                                          onPressed: () => context.pop(),
                                          icon: Icon(
                                            Icons.close,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                      vGap(10),
                                      Container(
                                        decoration: AppDecorations.containerDecoration,
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading:Icon(Icons.fitness_center, color: AppColors.grey,) ,
                                              title: Text(s.service, style: AppTextStyles.font14GreyRegular,),
                                              trailing:Text(coach.service, style: AppTextStyles.font16WhiteBold,) ,
                                            ),
                                            ListTile(
                                              leading:Icon(Icons.timer_outlined , color: AppColors.grey,) ,
                                              title: Text(s.turnaround, style: AppTextStyles.font14GreyRegular,),
                                              trailing:Text(coach.turnaround, style: AppTextStyles.font16WhiteBold,) ,
                                            ),
                                            const Divider(),
                                            ListTile(
                                              title: Text(s.total, style: AppTextStyles.font14GreyRegular,),
                                              trailing:Text(coach.price.toString(), style: AppTextStyles.font16WhiteBold,) ,
                                            ),
                                          ],
                                        ),
                                      ),
                                      vGap(10),
                                      Row(
                                        children: [
                                          Expanded(child: CustomButton(text: s.cancel, onPressed: () => context.pop(),color:AppColors.grey ,)),
                                          hGap(5),
                                          Expanded(child: CustomButton(text: s.confirm_and_pay, onPressed: ()=> context.pushReplacement(RequestSentScreen.routeName),)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) => vGap(10),
              itemCount: state.coaches.length,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String getInitials(String fullName) {
    if (fullName.trim().isEmpty) return '';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return fullName[0];
  }
}
