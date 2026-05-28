import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/services/api_client.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/coach/home/ui/widgets/home_tab.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../member/home/manager/bottom_nav_bar_cubit.dart';
import '../../../calender/widgets/calender_tab.dart';
import '../../../chat/widgets/coach_chat_tab.dart';
import '../../../members/widgets/members_tab.dart';
import '../../../profile/widgets/profile_tab.dart';
import '../widgets/coach_bottom_nav_bar_view_body.dart';

class CoachBottomNavBarView extends StatefulWidget {
  const CoachBottomNavBarView({super.key});
  static const String routeName = '/coach-nav';

  @override
  State<CoachBottomNavBarView> createState() => CoachBottomNavBarViewState();
}

class CoachBottomNavBarViewState extends State<CoachBottomNavBarView> {
  String _coachName = 'Coach';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    try {
      final res = await ApiClient.get('/auth/me');
      final name = res['data']?['name'] as String? ?? 'Coach';
      if (mounted) setState(() => _coachName = name.split(' ').first);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> bodies = [
      const HomeTab(),
      const MembersTab(),
      const CalenderTab(),
      const CoachChatTab(),
      const CoachProfileTab(),
    ];

    return BlocProvider(
      create: (_) => BottomNavBarCubit(),
      child: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 72,
              backgroundColor: AppColors.primary,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi, $_coachName 👋',
                      style: AppTextStyles.font16WhiteBold),
                  Text('Welcome to your dashboard',
                      style: AppTextStyles.font14GreyRegular
                          .copyWith(fontSize: 12.sp)),
                ],
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: AppColors.teal.withValues(alpha: 0.2),
                  child: Icon(Icons.sports_gymnastics,
                      color: AppColors.teal, size: 20.r),
                ),
              ),
            ),
            backgroundColor: AppColors.primary,
            body: BlocBuilder<BottomNavBarCubit, BottomNavBarState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: bodies[context.read<BottomNavBarCubit>().currentIndex],
                );
              },
            ),
            bottomNavigationBar: const CoachBottomNavBarViewBody(),
          ),
        ),
      ),
    );
  }
}
