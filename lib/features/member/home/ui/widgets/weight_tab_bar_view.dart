import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/helpers/spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

class WeightTabBarView extends StatelessWidget {
  const WeightTabBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(

      builder: (context, state) {
        final s = S.of(context);

        if (state is MemberLoading) {
          return const CircularProgressIndicator();
        }

        if (state is MemberLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: AppDecorations.containerDecoration
                    .copyWith(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.emerald,
                      width: 7,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    '${state.member.weight!.toStringAsFixed(1)} KG',
                    style: AppTextStyles.font16WhiteBold.copyWith(
                      fontSize: 24.sp,
                    ),
                  ),
                ),
              ),
              vGap(10),
              Text(
                s.update_current_weight,
                style: AppTextStyles.font16GreyRegular,
              ),
              vGap(5),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap : context.read<MemberCubit>().decreaseWeight,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration:
                        AppDecorations.containerDecoration,
                        child: Text('+ 0.1' , style: AppTextStyles.font16WhiteBold,),
                      ),
                    ),
                  ),
                  hGap(10),
                  Expanded(
                    child: InkWell(
                      onTap:context.read<MemberCubit>().increaseWeight,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration:
                        AppDecorations.containerDecoration,
                        child: Text('- 0.1' , style: AppTextStyles.font16WhiteBold,),

                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
