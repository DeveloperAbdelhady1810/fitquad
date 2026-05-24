import 'package:flutter/material.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/features/auth/ui/widgets/sign_up_view_body.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});
  static const String routeName='/signup';


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SignUpViewBody(),
      ),
    );
  }
}
