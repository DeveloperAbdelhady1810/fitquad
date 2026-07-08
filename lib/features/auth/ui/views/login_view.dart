import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/skin/app_skin_cubit.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/neo_theme.dart';
import 'package:gym_app/features/auth/ui/widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const String routeName='/login';

  @override
  Widget build(BuildContext context) {
    final isNeo = context.watch<AppSkinCubit>().state == AppSkin.neo;
    return SafeArea(
      child: Scaffold(
       backgroundColor: isNeo ? NeoColors.bg : AppColors.primary,
      body: LoginViewBody(),
    ),
    );
  }
}
