import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/features/member/home/ui/views/bottom_nav_bar_view.dart';

import '../../../../generated/l10n.dart';

class LoadingScreen extends StatefulWidget {
  static const routeName = '/generatingPlan';

  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  @override
  void initState() {
    super.initState();

  Future.delayed(const Duration(seconds: 2), () {
    if(!mounted) return;
    context.go(BottomNavBarView.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppColors.emerald,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            Text(
              s.generating_your_plan,
              style: AppTextStyles.font16WhiteBold,
            ),
            vGap(5),
            Text(
              s.analyzing_your_metrics,
              style: AppTextStyles.font16GreyRegular,
            ),

          ],
        ),
      ),
    );
  }
}