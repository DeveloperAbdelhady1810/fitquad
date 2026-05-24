import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/helpers/spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/custom_button.dart';
import '../../../../../../generated/l10n.dart';

import '../../../../home/manager/bottom_nav_bar_cubit.dart';
import 'cart_app_bar.dart';

class EmptyCartWidget extends StatefulWidget {
  const EmptyCartWidget({super.key});

  @override
  State<EmptyCartWidget> createState() => _EmptyCartWidgetState();
}

class _EmptyCartWidgetState extends State<EmptyCartWidget> {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CartAppBar(),
            Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.babyBlue,
                      size: 70.sp,
                    ),
                  ),
                  vGap(15),
                  Text(s.cart_empty, style: AppTextStyles.font16GreyRegular),
                  vGap(15),
                  Text(
                    s.shop,
                    style: AppTextStyles.font14GreyRegular,
                    textAlign: TextAlign.center,
                  ),
                  CustomButton(
                      width: 150,
                      text: s.start_shopping,
                      onPressed: () {


                        context.read<BottomNavBarCubit>().changeIndex(3);
                      }

                  ),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}
