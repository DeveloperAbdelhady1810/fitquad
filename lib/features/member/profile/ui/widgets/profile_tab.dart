import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/app_decoration.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/manager/member_state.dart';
import 'package:gym_app/features/member/inbody/ui/inbody_screen.dart';

import '../../../../../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEnglish = false;
  bool isNotificationsOn = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocBuilder<MemberCubit, MemberState>(
        builder: (context, state) {
          final name = state is MemberLoaded
              ? (state.member.name ?? 'Member')
              : '...';
          final memberType = state is MemberLoaded
              ? (state.member.type?.name ?? 'Member')
              : 'Member';
          final isActive = state is MemberLoaded &&
              state.member.status?.name == 'active';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44.r,
                      backgroundColor: Colors.grey,
                      child: CircleAvatar(
                        radius: 40.r,
                        backgroundColor: AppColors.secondary,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: AppTextStyles.font24GreyBold.copyWith(
                            fontSize: 32.sp,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 24.r,
                        width: 24.r,
                        decoration: BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: Icon(
                          Icons.qr_code_2,
                          color: Colors.white,
                          size: 14.r,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              vGap(15),
              Text(name, style: AppTextStyles.font16WhiteBold),
              vGap(5),
              Text('Member since 2025', style: AppTextStyles.font14GreyRegular),
              vGap(10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color(0xFF072518),
                  border: Border.all(
                    color: isActive ? AppColors.emerald : AppColors.grey,
                  ),
                ),
                child: Text(
                  isActive ? 'Pro Member' : memberType,
                  style: AppTextStyles.font14GreyRegular.copyWith(
                    color: isActive ? AppColors.emerald : AppColors.grey,
                  ),
                ),
              ),
              vGap(20),
              Text(s.account, style: AppTextStyles.font16GreyRegular),
              vGap(10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: AppDecorations.containerDecoration,
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.person_outline, color: AppColors.grey),
                      title: Text(
                        s.personal_details,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.grey,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.grey,
                      ),
                      title: Text(
                        s.membership_billing,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.grey,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.refresh, color: AppColors.grey),
                      title: Text(
                        s.visit_history,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.grey,
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.monitor_weight_outlined,
                          color: AppColors.teal),
                      title: Text('InBody Results',
                          style: AppTextStyles.font16WhiteRegular),
                      subtitle: Text('Track body composition',
                          style: AppTextStyles.font14GreyRegular
                              .copyWith(fontSize: 11.sp)),
                      trailing: Icon(Icons.arrow_forward_ios_outlined,
                          color: AppColors.grey),
                      onTap: () => context.push(InBodyScreen.routeName),
                    ),
                  ],
                ),
              ),
              vGap(15),
              Text(s.settings, style: AppTextStyles.font16GreyRegular),
              vGap(10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: AppDecorations.containerDecoration,
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          Icon(Icons.notifications_outlined, color: AppColors.grey),
                      title: Text(
                        s.notifications,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Switch(
                        activeThumbColor: AppColors.emerald,
                        value: isNotificationsOn,
                        onChanged: (value) {
                          setState(() => isNotificationsOn = value);
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(
                        Icons.language,
                        color: AppColors.grey,
                      ),
                      title: Text(
                        s.language,
                        style: AppTextStyles.font16WhiteRegular,
                      ),
                      trailing: Switch(
                        activeThumbColor: AppColors.emerald,
                        value: isEnglish,
                        onChanged: (value) {
                          setState(() => isEnglish = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
