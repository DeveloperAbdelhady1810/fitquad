import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/eat/widgets/plan_ready_screen.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';

import '../../../../../generated/l10n.dart';

class RequestSentScreen extends StatefulWidget {
  const RequestSentScreen({super.key});
  static const String routeName = '/request-sent';

  @override
  State<RequestSentScreen> createState() => _RequestSentScreenState();
}

class _RequestSentScreenState extends State<RequestSentScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if(!mounted) return;
      context.pushReplacement(PlanReadyScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
      ),
      backgroundColor: AppColors.primary,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
            child: Icon(
              Icons.access_time,
              color: AppColors.blue,
              size: 50,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              s.request_sent,
              style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 20),
            ),
          ),
          TextButton(
            onPressed: () => context.pushReplacement(BottomNavBarView.routeName),
            child: Text(
              s.back_to_dashboard,
              style: AppTextStyles.font16GreyRegular,
            ),
          ),
        ],
      ),
    );
  }
}