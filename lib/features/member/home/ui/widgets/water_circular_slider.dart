import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../manager/member_cubit.dart';
import '../../manager/member_state.dart';

class WaterSlider extends StatelessWidget {
  const WaterSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        if (state is MemberLoaded) {
          final member = state.member;
          final water = member.waterL ?? 0.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SleekCircularSlider(
                min: 0,
                max: 10,
                initialValue: water,
                onChange: (val) {
                  context.read<MemberCubit>().updateWaterL(val);
                },
                appearance: CircularSliderAppearance(
                  startAngle: 270,
                  angleRange: 360,
                  size: 200,
                  customColors: CustomSliderColors(
                    trackColor: Colors.grey.shade300,
                    progressBarColor: AppColors.purple,
                    dotColor: AppColors.grey,
                  ),
                  infoProperties: InfoProperties(
                    mainLabelStyle: AppTextStyles.font16WhiteBold.copyWith(fontSize: 30.sp),
                    modifier: (val) => '${val.toStringAsFixed(1)} L',
                  ),
                ),
              ),
              vGap(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    
                    style: ElevatedButton.styleFrom(shape: CircleBorder(), padding: EdgeInsets.all(15)),
                    onPressed: () {
                      double newVal = (water - 0.3).clamp(0, 10);
                      context.read<MemberCubit>().updateWaterL(newVal);
                    },
                    child: Text(
                      '-',
                      style: AppTextStyles.font16BlackRegular.copyWith(
                        fontSize: 25.sp,
                      ),
                    ),
                  ),
                  hGap(20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: CircleBorder(), backgroundColor: AppColors.purple,padding: EdgeInsets.all(15)),

                    onPressed: () {
                      double newVal = (water + 0.3).clamp(0, 10);
                      context.read<MemberCubit>().updateWaterL(newVal);
                    },
                    child: Text(
                      '+',
                      style: AppTextStyles.font16WhiteRegular.copyWith(
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (state is MemberLoading) {
          return const CircularProgressIndicator();
        } else {
          return const Text('Error loading member');
        }
      },
    );
  }
}
