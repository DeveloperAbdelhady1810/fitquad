import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';

import '../../../../../generated/l10n.dart';
import '../../manager/cart_cubit.dart';
import '../../manager/cart_state.dart';
import '../../manager/market_cubit.dart';
import '../views/cart_view.dart';
import 'market_tabs.dart';
import 'market_grid_view.dart';

class MarketTab extends StatelessWidget {
  const MarketTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s =S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.market,
              style: AppTextStyles.font16WhiteBold.copyWith(fontSize: 25.sp),
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final itemCount = state is CartLoaded
                    ? state.items.fold<int>(0, (sum, item) => sum + item.quantity)
                    : 0;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => context.push(CartView.routeName),
                      icon: Icon(Icons.shopping_cart_outlined, color: AppColors.white),
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            itemCount.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 12.sp),
                          ),
                        ),
                      ),
                  ],
                );
              },
            )

          ],
        ),
        vGap(15),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: CustomTextFormField(
                icon: Icons.search,
                textInputType: TextInputType.text,
                hintText: s.search_products,
                onChanged: (value) {
                  context.read<MarketCubit>().searchProducts(value??'');
                },
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.filter_list, color: Colors.white),
              ),
            ),
          ],
        ),
        vGap(15),
        const MarketTabs(),
        vGap(15),
        const Expanded(child: MarketGridView()),
      ],
    );
  }
}
