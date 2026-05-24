import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/features/auth/ui/widgets/loading_screen.dart';

import '../../../../generated/l10n.dart';
import '../../manager/onboarding_cubit.dart';
import '../widgets/availability_screen.dart';
import '../widgets/duration_screen.dart';
import '../widgets/summary_screen.dart';
import '../widgets/your_goal_screen.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});
  static const String routeName = '/survey';

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _controller = PageController();
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.primary,
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text('${currentStep + 1}/4' , style: AppTextStyles.font14GreyRegular,),
                LinearProgressIndicator(
                    color: AppColors.emerald,
                    value: (currentStep + 1) / 4),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => currentStep = index);
                    },
                    children: const [
                      StepGoal(),
                      StepAvailability(),
                      StepDuration(),
                      StepSummary(),
                    ],
                  ),
                ),
              const Divider(),
                Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: CustomButton(

                          color: AppColors.black.withValues(alpha: 0.5),
                          iconData: Icons.arrow_back_ios_new,
                          text: s.back,
                          iconBeforeText: true,
                          onPressed: () {
                            _controller.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),

                    if (currentStep > 0)
                      hGap(10),

                    Expanded(
                      flex: currentStep == 0 ? 1 : 2,
                      child: CustomButton(
                        iconData: Icons.arrow_forward_ios_outlined,
                        text: currentStep == 3 ? s.generate_plan : s.continu,
                        onPressed: () async {
                          if (currentStep < 3) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            await context.read<OnboardingCubit>().submit();
                            if (context.mounted) context.go(LoadingScreen.routeName);
                          }
                        },
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
