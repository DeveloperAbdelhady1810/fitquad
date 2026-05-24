import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/helpers/spacing.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../home/manager/bottom_nav_bar_cubit.dart';



class CartAppBar extends StatelessWidget {
  const CartAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(s.my_cart, style: AppTextStyles.font20WhiteRegular),
            TextButton(
              onPressed: () =>
                  context.read<BottomNavBarCubit>().changeIndex(3),
              child: Text(
                s.close,
                style: AppTextStyles.font14WhiteRegular,
              ),
            ),
          ],
        ),

        vGap(5),
        Divider(color: AppColors.grey, thickness: 1),
      ],
    );
  }
}
